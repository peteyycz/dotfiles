{ ... }:
{
  flake.modules.nixos.logitech = {
    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
  };
}
