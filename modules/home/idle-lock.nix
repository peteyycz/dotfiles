{ inputs, config, ... }:
let
  glass = inputs.hare.lib.glass;
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.idle-lock =
    { config, ... }:
    let
      wallpaper = "${config.home.homeDirectory}/${config.peteyycz.wallpaperPath}";
    in
    {
      services.hypridle = {
        enable = true;
        settings = {
          general = {
            lock_cmd = "pidof hyprlock || hyprlock";
            before_sleep_cmd = "loginctl lock-session";
            after_sleep_cmd = "hyprctl dispatch dpms on";
          };
          listener = [
            {
              timeout = 300;
              on-timeout = "loginctl lock-session";
            }
            {
              timeout = 330;
              on-timeout = "hyprctl dispatch dpms off";
              on-resume = "hyprctl dispatch dpms on";
            }
          ];
        };
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            grace = 0;
          };

          background = [
            {
              path = wallpaper;
              blur_passes = 3;
              blur_size = 8;
              color = "rgba(${glass.bg}aa)";
            }
          ];

          label = [
            {
              text = "$TIME";
              color = "rgb(${glass.fg})";
              font_size = 64;
              font_family = fonts.sans;
              position = "0, 160";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              size = "320, 52";
              outline_thickness = 2;
              rounding = 14;
              dots_size = 0.25;
              dots_spacing = 0.3;
              inner_color = "rgba(${glass.surface}cc)";
              outer_color = "rgba(${glass.accent}ff)";
              check_color = "rgba(${glass.accent}ff)";
              fail_color = "rgba(${glass.error}ff)";
              font_color = "rgb(${glass.fg})";
              placeholder_text = "";
              fade_on_empty = false;
              position = "0, -40";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };
    };
}
