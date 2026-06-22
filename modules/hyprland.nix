# GNOME desktop, display server, audio, printing, and dconf settings.
{pkgs, ...}: {
  programs.hyprland.enable = true;

  environment.systemPackages = with pkgs; [
    kitty
    waybar
    wofi
    nitch
    nemo
    hyprlauncher
  ];
}
