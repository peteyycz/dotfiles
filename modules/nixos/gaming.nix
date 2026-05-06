{ ... }:
{
  flake.modules.nixos.gaming =
    { pkgs, ... }:
    {
      programs.steam.enable = true;
      programs.steam.gamescopeSession.enable = true;

      networking.networkmanager.wifi.powersave = false;

      environment.systemPackages = with pkgs; [
        mangohud
      ];

      programs.gamemode.enable = true;
    };
}
