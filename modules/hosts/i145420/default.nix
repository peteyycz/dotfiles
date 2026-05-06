{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.i145420.module = {
    imports = [
      nixos.i145420-hardware
      nixos.i145420-configuration
      nixos.common
      nixos.disko
      nixos.secureboot
      nixos.luks-tpm2
      nixos.hibernation
      nixos.laptop
      nixos.u2f
    ];

    home-manager.users.${config.username}.imports = builtins.attrValues homeManager;
  };
}
