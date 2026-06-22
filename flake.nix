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
    # Build/switch with:  sudo nixos-rebuild switch --flake ~/nixos#nixos
    # (the host attr name "nixos" matches networking.hostName)
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

    # Per-project Rust dev environment. In any project folder:
    #   nix flake init -t ~/nixos#rust     (or use the `rust-init` shell helper)
    templates.rust = {
      path = ./templates/rust;
      description = "Rust devshell (fenix) with a per-project toolchain + target";
    };
    
    templates.default = self.templates.rust;

    # `nix fmt` formats the whole repo.
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
