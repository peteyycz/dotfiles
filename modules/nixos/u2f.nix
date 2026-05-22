{ ... }:
{
  flake.modules.nixos.u2f = {
    security.pam.u2f = {
      enable = true;
      settings.cue = true;
    };
    security.pam.services.sudo.u2fAuth = true;
    security.pam.services.sddm.u2fAuth = true;
  };
}
