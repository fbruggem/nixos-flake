# System packages, unfree allowance, and nix-ld (so LazyVim/Mason binaries run).
{
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  # nix-ld provides a standard dynamic linker so prebuilt binaries (e.g. the
  # tools Mason downloads for Neovim) run on NixOS. This is what makes the
  # LazyVim setup "just work" here.
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
    ];
  };

  environment.systemPackages =
    (with pkgs; [
      # Apps
      ghostty
      tmux
      discord
      spotify
      (symlinkJoin {
        name = "anki";
        paths = [anki];
        buildInputs = [makeWrapper];
        postBuild = ''
          wrapProgram $out/bin/anki --set QT_QPA_PLATFORM xcb
        '';
      })

      # Editor + CLI
      neovim
      fzf
      ripgrep
      xclip
      tree-sitter
      nodejs

      # C / systems programming
      man-pages
      clang
      clang-tools # clangd
      gdb

      # Rust: per-project devshells provide a matched rust-analyzer; this is a
      # global fallback for editing Rust files outside a devshell.
      rust-analyzer

      # Nix tooling
      alejandra # formatter (`nix fmt`)
      nil # nix language server
    ])
    ++ [
      # Zen browser comes from its flake input, pinned via flake.lock.
      inputs.zen-browser.packages.${pkgs.system}.default
    ];
}
