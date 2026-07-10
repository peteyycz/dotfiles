{ ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam.enable = true;
      programs.steam.gamescopeSession.enable = true;

      boot.extraModprobeConfig = "options bluetooth disable_ertm=1";

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
