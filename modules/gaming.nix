# System packages, unfree allowance, and nix-ld (so LazyVim/Mason binaries run).
{
  pkgs,
  inputs,
  ...
}: {

  programs.steam.enable = true;
  hardware.xpadneo.enable = true;

boot.extraModprobeConfig = ''
  options bluetooth disable_ertm=1
'';
}
