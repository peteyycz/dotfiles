{ config, ... }:
{
  flake.modules.nixos.homepc-configuration = {
    networking.hostName = "homepc";
    boot.initrd.kernelModules = [ "amdgpu" ];
    system.stateVersion = "25.11";

    home-manager.users.${config.username}.peteyycz.primaryMonitors = [
      "DP-1"
      "DP-2"
      "DP-3"
      "HDMI-A-1"
    ];
  };
}
