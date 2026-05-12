{ config, ... }:
{
  flake.modules.nixos.onepassword = {
    programs._1password.enable = true;
    programs._1password-gui = {
      enable = true;
      polkitPolicyOwners = [ config.username ];
    };
    security.pam.services."1password" = { };
  };
}
