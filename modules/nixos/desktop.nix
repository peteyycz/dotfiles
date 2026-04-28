{ ... }:
{
  flake.modules.nixos.desktop = { lib, pkgs, ... }: {
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config = {
        common = {
          default = "gtk";
          "org.freedesktop.impl.portal.Screenshot" = "wlr";
          "org.freedesktop.impl.portal.ScreenCast" = "wlr";
        };
        Hyprland = {
          default = lib.mkForce [ "hyprland" "gtk" ];
          "org.freedesktop.impl.portal.Settings" = [ "gtk" ];
          # xdg-desktop-portal-hyprland's restore-token persistence is incomplete
          # (logs "v3 todo with data"), so route screencast/screenshot to wlr
          # which persists tokens via xdg-permission-store.
          "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
          "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        };
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    services.displayManager = {
      defaultSession = "hyprland";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };
  };
}
