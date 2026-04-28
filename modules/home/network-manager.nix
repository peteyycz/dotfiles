{ ... }:
{
  flake.modules.homeManager.network-manager-applet = {
    services.network-manager-applet.enable = true;
  };
}
