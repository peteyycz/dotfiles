{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.apps =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        eternal-terminal # `et` client for reconnecting shells to homepc
        libnotify
        jq
        htop
        uv
        ffmpeg
        kubectx
        papirus-icon-theme
        nordzy-icon-theme
        mongodb-compass
        libreoffice
        kdePackages.merkuro
        kdePackages.kdepim-runtime
        kdePackages.akonadi
      ];

      programs.ghostty = {
        enable = true;
        settings = {
          font-family = fonts.mono;
          font-style = "Medium";
          font-size = 10.5;

          window-padding-x = 7;
          window-padding-y = 7;
          copy-on-select = "clipboard";
          # Slow the mouse wheel down (default is 3).
          mouse-scroll-multiplier = 1;

          # Gruvbox ships as a built-in ghostty theme; prefer it over a
          # hand-maintained palette. Theme names match the shipped filename
          # verbatim, not a slugified form.
          theme = "Gruvbox Dark";
        };
      };
    };
}
