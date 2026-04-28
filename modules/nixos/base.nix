{ ... }:
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      nix.settings.experimental-features = [
        "nix-command"
        "flakes"
      ];

      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.consoleMode = "max";
      boot.loader.efi.canTouchEfiVariables = true;

      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.kernelParams = [
        "quiet"
        "loglevel=3"
        "rd.systemd.show_status=auto"
        "rd.udev.log_level=3"
      ];
      boot.consoleLogLevel = 0;
      boot.initrd.verbose = false;
      boot.plymouth.enable = true;

      time.timeZone = "Europe/Budapest";
      i18n.defaultLocale = "en_US.UTF-8";
      console.font = "Lat2-Terminus16";

      services.gvfs.enable = true;
      services.udisks2.enable = true;
      services.tumbler.enable = true;
      services.upower.enable = true;

      services.libinput.enable = true;

      programs.nix-ld.enable = true;

      systemd.tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
      ];
    };
}
