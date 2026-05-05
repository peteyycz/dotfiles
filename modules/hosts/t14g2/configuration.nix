{ config, ... }:
{
  flake.modules.nixos.t14g2-configuration = {
    networking.hostName = "t14g2";
    boot.initrd.kernelModules = [ "i915" ];
    system.stateVersion = "25.11";

    peteyycz.disk = {
      device = "/dev/nvme0n1";
      swapSizeMiB = 15822;
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
