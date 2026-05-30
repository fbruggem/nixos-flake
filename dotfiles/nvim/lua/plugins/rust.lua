-- Rust + C language support.
--
-- Toolchain & rust-analyzer come from each project's fenix devshell (so the
-- LSP always matches the project's toolchain/target). A global `rust-analyzer`
-- is installed via Nix as a fallback for editing outside a devshell.
--
-- ── Per-project rust-analyzer settings ───────────────────────────────────
-- Easiest: set `[build] target = "..."` in the project's .cargo/config.toml —
-- rust-analyzer reads it natively, so cargo and the editor agree.
--
-- For rust-analyzer-only tweaks, drop a `rust-analyzer.json` in the project
-- root containing the INNER settings, e.g.:
--   {
--     "cargo":   { "target": "i686-unknown-linux-gnu", "allTargets": false },
--     "imports": { "preferNoStd": true },
--     "check":   { "allTargets": false }
--   }
-- It is deep-merged over the defaults, per project.

local function load_project_ra_settings(project_root, default_settings)
  local settings = default_settings or {}
  project_root = project_root
    or (vim.fs.root and vim.fs.root(0, { "rust-analyzer.json", "Cargo.toml", ".git" }))
    or vim.fn.getcwd()

  local path = project_root .. "/rust-analyzer.json"
  local fd = io.open(path, "r")
  if fd then
    local content = fd:read("*a")
    fd:close()
    local ok, decoded = pcall(vim.json.decode, content)
    if ok and type(decoded) == "table" then
      settings = vim.tbl_deep_extend("force", settings, { ["rust-analyzer"] = decoded })
    else
      vim.schedule(function()
        vim.notify("rust-analyzer.json: invalid JSON, ignoring", vim.log.levels.WARN)
      end)
    end
  end
  return settings
end

return {
  -- C / C++ (clangd). Mason's clangd runs thanks to nix-ld; clang-tools is
  -- also on PATH from Nix as a fallback.
  { import = "lazyvim.plugins.extras.lang.clangd" },

  -- Rust: pulls in rustaceanvim + treesitter (rust, toml) + crates.nvim.
  { import = "lazyvim.plugins.extras.lang.rust" },

  -- Hook our per-project settings loader into rustaceanvim. rustaceanvim
  -- calls `settings(project_root, default_settings)` when starting the LSP.
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      opts.server = opts.server or {}
      opts.server.settings = load_project_ra_settings
      return opts
    end,
  },
}
