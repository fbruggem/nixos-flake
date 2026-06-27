# Aggregates every system module. `./modules` in flake.nix resolves here.
{...}: {
  imports = [
    ./system.nix
    ./gaming.nix
    ./desktop.nix
    ./packages.nix
    ./home.nix
  ];
}
