{ config, ... }:
{
  flake.modules.nixos.homepc-configuration = {
    networking.hostName = "homepc";
    boot.initrd.kernelModules = [ "amdgpu" ];
    system.stateVersion = "25.11";
  };
}
