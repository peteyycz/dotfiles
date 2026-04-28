{ ... }:
{
  flake.modules.nixos.desktop =
    { lib, pkgs, ... }:
    let
      wallpaper = pkgs.fetchurl (import ../../wallpaper.nix);
      pixie-sddm-theme = pkgs.stdenvNoCC.mkDerivation {
        pname = "pixie-sddm";
        version = "3.0";
        src = pkgs.fetchFromGitHub {
          owner = "xCaptaiN09";
          repo = "pixie-sddm";
          rev = "6f2e77c269c43a455bd81c3ecac1fff796c0253c";
          hash = "sha256-NkjWP/y3kLRjYM0Wr3l7ndbMx3XYxQFXy07C28vrUSU=";
        };
        dontBuild = true;
        installPhase = ''
          runHook preInstall
          mkdir -p $out/share/sddm/themes/pixie
          cp -r assets components Main.qml metadata.desktop theme.conf LICENSE \
            $out/share/sddm/themes/pixie/
          cp ${wallpaper} $out/share/sddm/themes/pixie/assets/background.jpg
          runHook postInstall
        '';
      };
    in
    {
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

      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      environment.systemPackages = [ pixie-sddm-theme ];

      services.displayManager = {
        defaultSession = "hyprland";
        sddm = {
          enable = true;
          wayland.enable = true;
          theme = "pixie";
          extraPackages = with pkgs.kdePackages; [
            qt5compat
            qtdeclarative
            qtsvg
          ];
        };
      };
    };
}
