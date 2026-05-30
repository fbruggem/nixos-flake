# home-manager wired in as a NixOS module (single rebuild manages both).
{username, ...}: {
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {inherit username;};

    users.${username} = {
      home.stateVersion = "26.05";

      # Dotfiles. Paths are relative to THIS file (modules/), hence ../dotfiles.
      home.file = {
        ".config/tmux/tmux.conf".source = ../dotfiles/tmux.conf;
        ".config/ghostty/config".source = ../dotfiles/ghostty;
        ".bashrc".source = ../dotfiles/bashrc;
        ".bash_profile".source = ../dotfiles/bash_profile;
        ".config/gdb/gdbinit".source = ../dotfiles/gdbinit;
        ".config/nvim" = {
          source = ../dotfiles/nvim;
          recursive = true;
        };
      };

      # direnv + nix-direnv: entering a project folder with an .envrc
      # (`use flake`) auto-loads its devshell. The shell hook itself is added
      # in dotfiles/bashrc (since .bashrc is a managed static file).
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
  };
}
