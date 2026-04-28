{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.t14g2.module = {
    imports = [
      nixos.t14g2-hardware
      nixos.t14g2-configuration
      nixos.common
      nixos.laptop
      nixos.fingerprint
      nixos.u2f
    ];

    home-manager.users.${config.username}.imports = builtins.attrValues homeManager;
  };
}
