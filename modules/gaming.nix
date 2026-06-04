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
      steam
    ])
    ++ [
      # Zen browser comes from its flake input, pinned via flake.lock.
      inputs.zen-browser.packages.${pkgs.system}.default
    ];
}
