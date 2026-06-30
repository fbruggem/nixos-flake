# GNOME desktop, display server, audio, printing, and dconf settings.
{pkgs, ...}: {
  # X / GNOME
  services.xserver.enable = true;

  # Keyboard layout (X11)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing
  services.printing.enable = true;

  # External-monitor brightness over DDC/CI.
  # hardware.i2c.enable loads the i2c-dev module, installs udev rules, and
  # creates the `i2c` group (fbruggem is added to it in system.nix). ddcutil
  # is the backend; the GNOME extension adds a brightness slider per external
  # monitor in the quick-settings panel (the internal panel keeps its own).
  hardware.i2c.enable = true;
  environment.systemPackages = with pkgs; [
    ddcutil
    gnomeExtensions.brightness-control-using-ddcutil
  ];

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
          # Enabled GNOME extensions. NOTE: this database has lockAll = true,
          # so this key is locked — any extension you want on must be listed
          # here (you won't be able to toggle extensions from the UI).
          "org/gnome/shell" = {
            enabled-extensions = [
              pkgs.gnomeExtensions.brightness-control-using-ddcutil.extensionUuid
            ];
          };
          "org/gnome/desktop/background" = {
            "picture-uri" = "file://${../dotfiles/wallpaper.jpg}";
            "picture-uri-dark" = "file://${../dotfiles/wallpaper.jpg}";
            "picture-options" = "zoom";
          };
          "org/gnome/desktop/screensaver" = {
            "picture-uri" = "file://${../dotfiles/wallpaper.jpg}";
          };
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
