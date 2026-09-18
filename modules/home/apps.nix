{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.apps =
    { pkgs, config, ... }:
    {
      home.packages = with pkgs; [
        eternal-terminal # `et` client for reconnecting shells to homepc
        thunderbird
        libnotify
        jq
        htop
        uv
        ffmpeg
        kubectx
        papirus-icon-theme
        mongodb-compass
        libreoffice
      ];

      programs.ghostty = {
        enable = true;
        settings = {
          # Open straight into tmux: the most recently used session, or a new
          # dotfiles session via tmuxw when no server is running. Applies to
          # every launch route (panel icon, krunner, `ghostty`); `ghostty -e
          # <cmd>` still overrides it. profileDirectory rather than a bare
          # name so it resolves regardless of the launcher's PATH.
          command = "${config.home.profileDirectory}/bin/tmux-attach-latest";

          font-family = fonts.mono;
          font-style = "SemiBold";
          font-size = 10.5;

          # Open maximized rather than at the default 80x24.
          maximize = true;

          # Just enough transparency to show the wallpaper through, with
          # KWin's blur behind it so text stays readable over busy areas.
          # The radius is only honoured on macOS — on Wayland ghostty just
          # flags the surface as blurred and KWin does the rendering, so the
          # strength lives in kwinrc's Effect-blur (set in plasma.nix).
          background-opacity = 0.9;
          background-blur = 64;

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
