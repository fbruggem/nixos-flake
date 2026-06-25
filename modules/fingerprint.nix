# Fingerprint authentication for the ThinkPad T480s.
#
# The T480s sensor is the Synaptics "Metallica MIS" (USB 06cb:009a), which
# mainline libfprint/fprintd does NOT support — it needs a proprietary firmware
# blob and the community python-validity driver. That driver is packaged by the
# `nixos-06cb-009a-fingerprint-sensor` flake (added in flake.nix); its module is
# imported below via specialArgs `inputs`.
#
# The flake's module enables and wires up fprintd for us, so we do NOT set
# `services.fprintd.enable` ourselves.
{inputs, ...}: {
  imports = [
    inputs.nixos-06cb-009a-fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"
  ];

  security.pam.services.sudo.fprintAuth = true;

  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
    # "python-validity": enroll + verify directly (what you want here).
    # "libfprint-tod": alternative that first needs a calib-data file extracted
    #   by python-validity — only worth it for the libfprint-tod integration.
    backend = "python-validity";
  };

  # Once fprintd is running, its standard PAM integration lets you authenticate
  # by fingerprint at the usual prompts (login, sudo, GDM). To turn it off for a
  # specific service — e.g. to keep the password field on the GDM login screen —
  # disable it per service:
  #   security.pam.services.gdm-password.fprintAuth = false;
}
