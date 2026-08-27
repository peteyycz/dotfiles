{ config, ... }:
{
  flake.modules.nixos.i145420-configuration = {
    networking.hostName = "i145420";
    boot.initrd.kernelModules = [ "i915" ];
    services.thermald.enable = true;
    system.stateVersion = "25.11";

    # Resolve the local dev vhosts to homepc over Tailscale instead of this
    # laptop's loopback. Get the stable value once with `tailscale ip -4` on
    # homepc, then replace the placeholder below.
    services.devHosts.target = "100.109.156.51"; # homepc tailnet IP

    peteyycz.disk = {
      device = "/dev/nvme0n1";
      swapSizeMiB = 64245;
    };
  };
}
