{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "homepc";

  boot.initrd.kernelModules = [ "amdgpu" ];

  security.pam.u2f = {
    enable = true;
    settings.cue = true;
  };

  security.pam.services.sudo.u2fAuth = true;
  security.pam.services.hyprlock.u2fAuth = true;
  security.pam.services.sddm.u2fAuth = true;

  # Has to do with some nixos internals DO NOT CHANGE
  system.stateVersion = "25.11";
}
