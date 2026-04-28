{ ... }:
{
  flake.modules.homeManager.fonts = {
    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        sansSerif = [ "Open Runde" "Symbols Nerd Font" ];
        monospace = [ "VictorMono Nerd Font Mono" "Symbols Nerd Font" ];
      };
    };
  };
}
