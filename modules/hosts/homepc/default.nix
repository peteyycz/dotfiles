{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.homepc.module = {
    imports = [
      nixos.homepc-hardware
      nixos.homepc-configuration
      nixos.base
      nixos.networking
      nixos.audio
      nixos.bluetooth
      nixos.fonts
      nixos.desktop
      nixos.sddm-pixie
      nixos.onepassword
      nixos.docker
      nixos.keyring
      nixos.neovim
      nixos.fish
      nixos.user
      nixos.packages
      nixos.u2f
      nixos.home-manager
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    home-manager.users.${config.username}.imports =
      builtins.attrValues (removeAttrs homeManager [ "laptop" ]);
  };
}
