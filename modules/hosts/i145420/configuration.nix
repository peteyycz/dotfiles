{ config, ... }:
{
  flake.modules.nixos.i145420-configuration = {
    networking.hostName = "i145420";
    boot.initrd.kernelModules = [ "i915" ];
    services.thermald.enable = true;
    system.stateVersion = "25.11";

    peteyycz.disk = {
      device = "/dev/nvme0n1";
      swapSizeMiB = 64245;
    };
  };
}
