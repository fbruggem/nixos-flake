-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- LSP servers are configured by LazyVim's language "extras" (loaded in
-- lua/plugins/). Rust uses rustaceanvim; see lua/plugins/rust.lua for the
-- per-project rust-analyzer.json mechanism. Do NOT call lspconfig.*.setup()
-- here — that conflicts with LazyVim and would start a second LSP client.
