# Aggregates every system module. `./modules` in flake.nix resolves here.
{...}: {
  imports = [
    ./fingerprint.nix
    ./system.nix
    ./desktop.nix
    ./packages.nix
    ./home.nix
  ];
}
