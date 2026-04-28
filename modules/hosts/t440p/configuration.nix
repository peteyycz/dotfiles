{ config, ... }:
{
  flake.modules.nixos.t440p-configuration = {
    networking.hostName = "t440p";
    boot.initrd.kernelModules = [ "i915" ];
    system.stateVersion = "25.11";

    home-manager.users.${config.username}.peteyycz.primaryMonitors = [
      "HDMI-A-1"
      "DP-1"
      "DP-2"
      "eDP-1"
    ];
  };
}
