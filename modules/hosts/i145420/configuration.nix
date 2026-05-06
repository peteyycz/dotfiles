{ config, ... }:
{
  flake.modules.nixos.i145420-configuration = {
    networking.hostName = "i145420";
    boot.initrd.kernelModules = [ "i915" ];
    system.stateVersion = "25.11";

    peteyycz.disk = {
      device = "/dev/nvme0n1";
      swapSizeMiB = 64245;
    };

    home-manager.users.${config.username}.peteyycz.primaryMonitors = [
      "DP-1"
      "DP-2"
      "DP-3"
      "HDMI-A-1"
      "eDP-1"
    ];
  };
}
