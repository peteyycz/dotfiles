{ ... }:
{
  flake.modules.nixos.fingerprint = {
    services.fprintd.enable = true;
    security.pam.services.sudo.fprintAuth = true;
    security.pam.services.sddm.fprintAuth = true;
  };
}
