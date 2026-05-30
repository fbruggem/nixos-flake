# nixos

Flakes-based NixOS configuration.

## Layout

```
flake.nix                 inputs (nixpkgs, home-manager, zen-browser) + outputs
flake.lock                pinned versions (commit this)
hardware-configuration.nix  machine-specific (you provide — see below)
modules/
  default.nix             imports the modules below
  system.nix              boot, nix, gc, autoUpgrade, users, locale, git
  desktop.nix             GNOME, display, audio, printing, dconf
  packages.nix            system packages, allowUnfree, nix-ld
  home.nix                home-manager + dotfile links + direnv
dotfiles/                 nvim, bash, tmux, ghostty, gdb
templates/rust/           per-project Rust devshell (fenix)
rebuild.sh                pull → rebuild → commit → push
```

## First-time migration (channels → flakes)

Flakes evaluate in *pure* mode and can't read `/etc/nixos`, so your hardware
config must live in the repo:

```sh
cp /etc/nixos/hardware-configuration.nix ~/nixos/
cd ~/nixos
git add -A          # important: flakes only see git-tracked files
sudo nixos-rebuild switch --flake ~/nixos#nixos
```

The placeholder `hardware-configuration.nix` throws on purpose until you replace
it. `nix-command` and `flakes` are already enabled in `modules/system.nix`.

## Daily use

```sh
rebuild                  # ~/nixos/rebuild.sh: pull, rebuild --flake, commit, push
```

Edit the files, then run `rebuild`. `system.autoUpgrade` also rebuilds daily at
06:00 from `github:fbruggem/nixos` (this replaces the old every-minute
git-pull/rebuild timers).

### Updating packages

Inputs are pinned in `flake.lock`. To pull in newer nixpkgs/home-manager:

```sh
nix flake update         # bump all inputs
# or: nix flake update nixpkgs
rebuild
```

## Rust workflow

Toolchains are declarative per project via [fenix](https://github.com/nix-community/fenix)
devshells — different folders can use different channels and targets, all pinned
in each project's own `flake.lock`.

Create an environment:

```sh
rust-init myproject      # scaffolds + cargo init + direnv allow
cd myproject             # direnv auto-loads the toolchain
cargo build
```

Each project gets:

- **`flake.nix`** — the `EDIT PER PROJECT` block sets the channel
  (`stable` / `beta` / `complete` = nightly) and `extraTargets`
  (prebuilt cross-compile std libs).
- **`.cargo/config.toml`** — set `[build] target = "..."`; both `cargo` and
  rust-analyzer pick it up. Commented examples cover cross targets and custom
  JSON / `build-std` (no_std, bare-metal) setups.
- **`.envrc`** — `use flake`, so the right toolchain loads on `cd`.

### Different targets per folder

- **Known cross target** (e.g. `i686-unknown-linux-gnu`): add it to
  `extraTargets` in `flake.nix`, set `[build] target` in `.cargo/config.toml`.
- **Custom JSON target** (e.g. `i386-unknown-none.json`, no_std): set
  `channelName = "complete"` (nightly) in `flake.nix`, then enable
  `[build] target` + `[unstable] build-std` in `.cargo/config.toml`.

### Editor

Neovim uses LazyVim + rustaceanvim (`dotfiles/nvim/lua/plugins/rust.lua`).
rust-analyzer comes from the project's devshell, so it always matches the
toolchain. For rust-analyzer-only tweaks, drop a `rust-analyzer.json` in the
project root — it's deep-merged over the defaults per project.

> Note: `nix flake init -t` only copies dotfiles that exist in the template;
> all of `flake.nix`, `.envrc`, `.cargo/config.toml`, `.gitignore` are included.
