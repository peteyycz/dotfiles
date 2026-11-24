{ ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam.enable = true;
      programs.steam.gamescopeSession.enable = true;

      # The Xbox One S pad (045E:02FD) advertises a malformed HID report
      # descriptor over Bluetooth ("unbalanced collection at end of report
      # description"), so both hid-generic and hid-microsoft refuse to probe
      # it and no input device is ever created. hid_xpadneo fixes up the
      # descriptor and adds correct mapping plus rumble.
      hardware.xpadneo.enable = true;

      # fnmode=2 (fkeysfirst) makes F1–F12 send plain function keys on every
      # hid_apple keyboard, with the media functions on Fn+F-key.
      #
      # The Keychron K8 reports Apple's 05ac:024f in firmware (the descriptor
      # only identifies itself as a Keychron via the product string), so
      # hid_apple claims it regardless of the Win/Mac switch position. The
      # parameter is driver-wide, not per-device.
      boot.extraModprobeConfig = ''
        options bluetooth disable_ertm=1
        options hid_apple fnmode=2
      '';

      networking.networkmanager.wifi.powersave = false;

      environment.systemPackages = with pkgs; [
        mangohud
        lutris
        protontricks
        discord
      ];

      programs.gamemode.enable = true;
    };
}
