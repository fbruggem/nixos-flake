{inputs, ...}: {
  imports = [
    inputs.nixos-06cb-009a-fingerprint-sensor.nixosModules."06cb-009a-fingerprint-sensor"
  ];

  security.pam.services.sudo.fprintAuth = true;

  services."06cb-009a-fingerprint-sensor" = {
    enable = true;
    backend = "python-validity";
  };

  # Once fprintd is running, its standard PAM integration lets you authenticate
  # by fingerprint at the usual prompts (login, sudo, GDM). To turn it off for a
  # specific service — e.g. to keep the password field on the GDM login screen —
  # disable it per service:
}
