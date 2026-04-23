{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/common.nix
  ];

  networking.hostName = "t14g2";

  boot.initrd.kernelModules = [ "i915" ];

  services.fprintd.enable = true;

  security.pam.services.sudo.fprintAuth = true;
  security.pam.services.hyprlock.fprintAuth = true;
  security.pam.services.sddm.fprintAuth = true;

  # Has to do with some nixos internals DO NOT CHANGE
  system.stateVersion = "25.11";
}
