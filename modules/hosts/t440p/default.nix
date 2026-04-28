{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.t440p.module = {
    imports = [
      nixos.t440p-hardware
      nixos.t440p-configuration
      nixos.common
      nixos.laptop
    ];

    home-manager.users.${config.username}.imports = builtins.attrValues homeManager;
  };
}
