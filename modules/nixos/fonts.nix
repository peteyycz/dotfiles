{ config, lib, ... }:
{
  options.fontFamilies = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
    default = {
      sans = "Open Runde";
      mono = "VictorMono Nerd Font Mono";
    };
    readOnly = true;
    description = "Font family names. Single source of truth shared by NixOS fontconfig and home-manager app configs.";
  };

  config.flake.modules.nixos.fonts = { pkgs, ... }:
    let
      open-runde = pkgs.stdenvNoCC.mkDerivation {
        pname = "open-runde";
        version = "1.0.1";
        src = pkgs.fetchzip {
          url = "https://github.com/lauridskern/open-runde/releases/download/v1.0.1/OpenRunde-1.0.1.zip";
          sha256 = "1nv2124hpkmvn5byk9xnm3vq7nh0ivlld0nndmm5dvw142mf222x";
          stripRoot = false;
        };
        installPhase = ''
          install -Dm644 -t $out/share/fonts/opentype "$src"/OpenRunde-1.0.1/desktop/*.otf
        '';
        meta = {
          description = "A soft, rounded variant of Inter";
          homepage = "https://github.com/lauridskern/open-runde";
          license = lib.licenses.ofl;
        };
      };
    in {
      fonts.packages = with pkgs; [
        open-runde
        inter
        nerd-fonts.victor-mono
        nerd-fonts.symbols-only
        nerd-fonts.jetbrains-mono
        papirus-icon-theme
        gruvbox-plus-icons
      ];

      fonts.fontconfig = {
        enable = true;
        defaultFonts = {
          sansSerif = [ config.fontFamilies.sans "Symbols Nerd Font" ];
          monospace = [ config.fontFamilies.mono "Symbols Nerd Font" ];
        };
      };
    };
}
