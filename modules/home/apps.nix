{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        libnotify
        jq
        htop
        uv
        ffmpeg
        kubectx
        papirus-icon-theme
        mongodb-compass
        libreoffice
        kdePackages.merkuro
        kdePackages.kdepim-runtime
        kdePackages.akonadi
      ];

      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "${fonts.mono}:style=Medium:size=8.5";
            pad = "7x7";
            selection-target = "clipboard";
            dpi-aware = "no";
          };
          url = {
            launch = "xdg-open \${url}";
          };
          key-bindings = {
            show-urls-launch = "Control+Shift+o";
          };
          mouse-bindings = {
            primary-paste = "none";
          };
          # Gruvbox Material (dark, medium), background cooled toward a neutral
          # dark and magenta swapped for a lavender accent.
          colors = {
            alpha = "1.0";
            background = "1a1b1e";
            foreground = "d4be98";
            regular0 = "3c3836";
            regular1 = "ea6962";
            regular2 = "a9b665";
            regular3 = "d8a657";
            regular4 = "7daea3";
            regular5 = "c4a8c4";
            regular6 = "89b482";
            regular7 = "d4be98";
            bright0 = "665c54";
            bright1 = "ea6962";
            bright2 = "a9b665";
            bright3 = "d8a657";
            bright4 = "7daea3";
            bright5 = "d8bdd8";
            bright6 = "89b482";
            bright7 = "ddc7a1";
          };
        };
      };
    };
}
