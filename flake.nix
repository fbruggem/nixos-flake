{
  description = "fbruggem's NixOS configuration";

  inputs = {
    # Track the 25.11 release. Bump this string to move releases.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # `follows` keeps home-manager on the SAME nixpkgs as the system,
    # so there's no version skew between the two.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    zen-browser,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "fbruggem";
  in {
    # Default setup for thinkpad-t480s
    nixosConfigurations.hyprland = nixpkgs.lib.nixosSystem {
      inherit system;
      # specialArgs makes `inputs` and `username` available to every module.
      specialArgs = {inherit inputs username;};
      modules = [
        ./hardware-configuration.nix
        ./modules/system.nix
        ./modules/home.nix
        ./modules/packages.nix
        ./modules/hyprland.nix
        home-manager.nixosModules.home-manager
      ];
    };

    nixosConfigurations.thinkpad-t480s = nixpkgs.lib.nixosSystem {
      inherit system;
      # specialArgs makes `inputs` and `username` available to every module.
      specialArgs = {inherit inputs username;};
      modules = [
        ./hardware-configuration.nix
        ./modules
        home-manager.nixosModules.home-manager
      ];
    };

    # `nix fmt` formats the whole repo.
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
