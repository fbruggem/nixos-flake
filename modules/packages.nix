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

  services.fprintd = {
    package = pkgs.fprintd-tod;
    tod = {
      enable = true;
      driver = pkgs.libfprint-2-tod1-goodix;
    };
  };

  environment.systemPackages =
    (with pkgs; [
      # Apps
      ghostty
      tmux
      discord
      spotify

      # Editor + CLI
      neovim
      fzf
      ripgrep
      xclip
      tree-sitter
      nodejs
      nil # nix language server
      busybox

      # C / systems programming
      man-pages
      clang
      clang-tools # clangd
      gdb
      claude-code
    ])
    ++ [
      # Zen browser comes from its flake input, pinned via flake.lock.
      inputs.zen-browser.packages.${pkgs.system}.default
    ];
}
