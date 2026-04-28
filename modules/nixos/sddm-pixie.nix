{ ... }:
{
  flake.modules.nixos.sddm-pixie = { pkgs, ... }:
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
    in {
      environment.systemPackages = [ pixie-sddm-theme ];
      services.displayManager.sddm = {
        theme = "pixie";
        extraPackages = with pkgs.kdePackages; [
          qt5compat
          qtdeclarative
          qtsvg
        ];
      };
    };
}
