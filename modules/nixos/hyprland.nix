{ ... }:
{
  flake.modules.nixos.hyprland =
    { lib, pkgs, ... }:
    {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      xdg.portal = {
        wlr.enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
        config.Hyprland = {
          default = lib.mkForce [
            "hyprland"
            "gtk"
          ];
          "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
          # xdg-desktop-portal-hyprland's restore-token persistence is incomplete
          # (logs "v3 todo with data"), so route screencast/screenshot to wlr
          # which persists tokens via xdg-permission-store.
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };
      };
    };
}
