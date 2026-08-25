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
      environment.systemPackages = [ pkgs.kdePackages.print-manager ];

      # mDNS/Avahi so CUPS can discover the Wi-Fi printer on the LAN.
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        openFirewall = true;
      };
    };
}
