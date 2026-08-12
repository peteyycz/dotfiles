{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.homepc.module = {
    imports = [
      nixos.homepc-hardware
      nixos.homepc-configuration
      nixos.common
      nixos.u2f
      nixos.gaming
    ];

    home-manager.users.${config.username} = {
      imports = builtins.attrValues (removeAttrs homeManager [ "laptop" ]);
      peteyycz.autostart = {
        steam = "steam -silent";
        discord = "discord --start-minimized";
      };
    };
  };
}
