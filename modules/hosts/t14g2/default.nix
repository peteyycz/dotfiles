{ config, ... }:
let
  inherit (config.flake.modules) nixos homeManager;
in
{
  configurations.nixos.t14g2.module = {
    imports = [
      nixos.t14g2-hardware
      nixos.t14g2-configuration
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
      nixos.laptop
      nixos.fingerprint
      nixos.home-manager
    ];

    nixpkgs.hostPlatform = "x86_64-linux";

    home-manager.users.${config.username}.imports = builtins.attrValues homeManager;
  };
}
