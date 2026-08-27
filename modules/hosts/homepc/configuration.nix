{ config, ... }:
{
  flake.modules.nixos.homepc-configuration = {
    networking.hostName = "homepc";
    boot.initrd.kernelModules = [ "amdgpu" ];
    system.stateVersion = "25.11";

    # Static LAN address on the wired interface. NetworkManager prefers this
    # explicit profile over its runtime-generated "Wired connection 1" default.
    networking.networkmanager.ensureProfiles.profiles.lan-static = {
      connection = {
        id = "lan-static";
        type = "ethernet";
        interface-name = "enp7s0";
        autoconnect = true;
        autoconnect-priority = 100;
      };
      ipv4 = {
        method = "manual";
        address1 = "192.168.0.201/24,192.168.0.1";
        dns = "1.1.1.1";
      };
      ipv6.method = "auto";
    };
  };
}
