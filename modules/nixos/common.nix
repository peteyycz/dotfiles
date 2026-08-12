{ config, ... }:
let
  inherit (config.flake.modules) nixos;
in
{
  flake.modules.nixos.common =
    { ... }:
    {
      imports = [
        nixos.base
        nixos.networking
        nixos.audio
        nixos.bluetooth
        nixos.logitech
        nixos.fonts
        nixos.desktop
        nixos.plasma
        nixos.onepassword
        nixos.docker
        nixos.keyring
        nixos.neovim
        nixos.fish
        nixos.user
        nixos.packages
        nixos.home-manager
      ];
    };
}
