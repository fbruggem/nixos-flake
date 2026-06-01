# Fingerprint reader support (fprintd).
#
# After rebuilding, enroll a finger in GNOME Settings → Users → Fingerprint
# Login, or run `fprintd-enroll` in a terminal (check it with `fprintd-verify`).
{
  config,
  lib,
  pkgs,
  ...
}: {
  services.fprintd.enable = true;

  # ── If the reader isn't detected ("No devices available") ────────────────
  # Some sensors (many Goodix / Elan, common on recent laptops) need the
  # proprietary "touch OEM driver". Identify yours in `lsusb`, then:
  # services.fprintd.tod = {
  #   enable = true;
  #   driver = pkgs.libfprint-2-tod1-goodix;   # or -elan / -goodix-550a / ...
  # };

  # ── GDM: keep password login working ─────────────────────────────────────
  # Enabling fprintd can make GDM and the lock screen prompt ONLY for a finger
  # and stop accepting your password. If that happens, this restores the
  # password fallback (NixOS issue #171136):
  # security.pam.services.login.fprintAuth = false;
  # security.pam.services.gdm-fingerprint = lib.mkIf config.services.fprintd.enable {
  #   text = ''
  #     auth required pam_shells.so
  #     auth requisite pam_nologin.so
  #     auth requisite pam_faillock.so preauth
  #     auth required ${pkgs.fprintd}/lib/security/pam_fprintd.so
  #     auth optional pam_permit.so
  #     auth required pam_env.so
  #     auth [success=ok default=1] ${pkgs.gdm}/lib/security/pam_gdm.so
  #     auth optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so
  #     account include login
  #     password required pam_deny.so
  #     session include login
  #     session optional ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
  #   '';
  # };
}
