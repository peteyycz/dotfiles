{ ... }:
{
  flake.modules.nixos.gaming =
    { ... }:
    {
      programs.steam.enable = true;
      networking.networkmanager.wifi.powersave = false;
    };
}
