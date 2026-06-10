{
  description = "C++98 dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs = {nixpkgs, ...}: let
    # Single-machine setup, same convention as the rust template.
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        gcc # g++ — -std=c++98 is set in the Makefile, not globally
        gnumake
        gdb
        valgrind
        clang-tools # clangd; reads ./compile_flags.txt for the c++98 mode
      ];

      shellHook = ''
        echo "g++ $(g++ -dumpversion)  |  C++98 (flags in Makefile + compile_flags.txt)"
      '';
    };

    formatter.${system} = pkgs.alejandra;
  };
}
