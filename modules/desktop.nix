# GNOME desktop, display server, audio, printing, and dconf settings.
{pkgs, ...}: {
  # X / GNOME
  services.xserver.enable = true;
  services.desktopManager.gnome.enable = true;
  services.displayManager.gdm.enable = true;

  # Keyboard layout (X11)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # Audio via PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # GNOME settings via dconf.
  # Discover keys with:
  #   gsettings list-schemas
  #   gsettings list-keys SCHEMA_NAME
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        settings = {
          "org/gnome/desktop/wm/keybindings" = {
            "switch-to-workspace-1" = ["<Alt>1"];
            "switch-to-workspace-2" = ["<Alt>2"];
            "switch-to-workspace-3" = ["<Alt>3"];
            "switch-to-workspace-4" = ["<Alt>4"];
            "toggle-fullscreen" = ["<Super>f"];
          };
          "org/gnome/desktop/wm/preferences" = {
            "num-workspaces" = pkgs.lib.gvariant.mkInt32 4;
          };
          "org/gnome/mutter" = {
            "dynamic-workspaces" = false;
          };
          "org/gnome/settings-daemon/plugins/media-keys" = {
            "search" = ["<Control>space"];
          };
          "org/gnome/desktop/input-sources" = {
            "xkb-options" = ["caps:escape"];
          };
          "org/gnome/desktop/interface" = {
            "enable-hot-corners" = false;
            enable-animations = false;
            "color-scheme" = "prefer-dark";
            "gtk-theme" = "Adwaita-dark";
          };
          "org/gnome/desktop/peripherals/mouse" = {
            natural-scroll = true;
          };
        };
        lockAll = true; # enforce the settings strictly
      }
    ];
  };
}
