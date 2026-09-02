{ ... }:
{
  flake.modules.nixos.plasma =
    { pkgs, ... }:
    {
      services.desktopManager.plasma6.enable = true;

      # Printing: CUPS plus the System Settings printer module. Without
      # print-manager, System Settings reports "Could not find plugin
      # kcm_printer_manager".
      services.printing.enable = true;
      # HP Envy 6020e (wireless all-in-one) driver.
      services.printing.drivers = [ pkgs.hplip ];
      environment.systemPackages = [
        pkgs.kdePackages.print-manager
        # Darkly application style + window decoration. It's the Plasma 6 fork
        # of Lightly (which was removed from nixpkgs as Plasma-5-only) and
        # provides both light and dark variants.
        pkgs.darkly
        # Extra KIO protocols (ftp://, sftp://, etc.) so Dolphin can browse
        # remote filesystems directly from the address bar.
        pkgs.kdePackages.kio-extras
      ];

      # mDNS/Avahi so CUPS can discover the Wi-Fi printer on the LAN.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
}
