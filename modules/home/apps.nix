{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.apps =
    {
      config,
      theme,
      pkgs,
      ...
    }:
    let
      inherit (theme) palette c;
    in
    {
      home.packages = with pkgs; [
        libnotify
        slurp
        wf-recorder
        jq
        grimblast
        uv
        ffmpeg
        networkmanagerapplet
        kubectx
      ];

      services.hyprpolkitagent.enable = true;

      programs.rofi = {
        enable = true;
        font = "${fonts.sans} 13";
        extraConfig = {
          modi = "drun,run,window";
          show-icons = true;
          icon-theme = "Papirus-Dark";
          display-drun = "";
          display-run = "";
          display-window = "";
          display-combi = "";
          drun-display-format = "{name}";
          kb-remove-char-forward = "Delete";
          kb-remove-to-sol = "";
          kb-page-prev = "Control+u";
          kb-page-next = "Control+d";
          kb-delete-entry = "";
        };
        theme =
          let
            inherit (config.lib.formats.rasi) mkLiteral;
          in
          {
            "*" = {
              bg = mkLiteral palette.bg;
              bg1 = mkLiteral palette.bg1;
              bg2 = mkLiteral palette.bg2;
              gray = mkLiteral palette.gray;
              fg3 = mkLiteral palette.fg3;
              fg = mkLiteral palette.fg;
              red = mkLiteral palette.red;
              yellow = mkLiteral palette.yellow;
              blue = mkLiteral palette.blue;
              purple = mkLiteral palette.purple;
              aqua = mkLiteral palette.aqua;
              background-color = mkLiteral "transparent";
              text-color = mkLiteral "@fg";
              highlight = mkLiteral "bold ${palette.purple}";
            };
            window = {
              width = mkLiteral "720px";
              location = mkLiteral "north";
              anchor = mkLiteral "north";
              y-offset = mkLiteral "20%";
              background-color = mkLiteral (theme.rgba palette.bg 0.5);
              border = mkLiteral "1px solid";
              border-color = mkLiteral (theme.rgba palette.fg 0.1);
              border-radius = mkLiteral "20px";
            };
            mainbox = {
              padding = mkLiteral "16px";
            };
            inputbar = {
              padding = mkLiteral "14px 18px";
              margin = mkLiteral "0 0 14px 0";
              background-color = mkLiteral (theme.rgba palette.bg1 0.35);
              border-radius = mkLiteral "12px";
              children = map mkLiteral [
                "textbox-prompt-colon"
                "entry"
              ];
            };
            prompt = {
              text-color = mkLiteral "@purple";
            };
            "textbox-prompt-colon" = {
              expand = false;
              str = " ";
            };
            entry = {
              placeholder = "Search...";
              placeholder-color = mkLiteral "@gray";
              text-color = mkLiteral "@fg";
            };
            listview = {
              lines = 5;
              columns = 1;
              fixed-height = false;
              dynamic = true;
              spacing = mkLiteral "4px";
            };
            element = {
              padding = mkLiteral "9px 14px";
              border-radius = mkLiteral "8px";
              spacing = mkLiteral "10px";
            };
            "element selected" = {
              background-color = mkLiteral (theme.rgba palette.purple 0.2);
              text-color = mkLiteral "@purple";
              border-radius = mkLiteral "8px";
            };
            element-icon = {
              size = mkLiteral "24px";
              margin = mkLiteral "0 10px 0 0";
            };
            element-text = {
              vertical-align = mkLiteral "0.5";
            };
          };
      };

      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            ignore_empty_input = true;
            hide_cursor = true;
            grace = 0;
          };

          background = [
            {
              monitor = "";
              path = "${config.home.homeDirectory}/${config.peteyycz.wallpaperPath}";
              blur_passes = 3;
              blur_size = 8;
            }
          ];

          input-field = [
            {
              monitor = "";
              size = "300, 60";
              position = "0, -80";
              halign = "center";
              valign = "center";
              outline_thickness = 4;
              dots_size = 0.25;
              dots_spacing = 0.4;
              dots_center = true;
              rounding = 30;
              outer_color = "rgb(${c palette.bg1})";
              inner_color = "rgb(${c palette.bg})";
              font_color = "rgb(${c palette.fg})";
              check_color = "rgb(${c palette.blueDark})";
              fail_color = "rgb(${c palette.red})";
              capslock_color = "rgb(${c palette.yellow})";
              placeholder_text = "<i>Password...</i>";
              fail_text = "<i>$FAIL ($ATTEMPTS)</i>";
              fade_on_empty = false;
            }
          ];

          label = [
            {
              monitor = "";
              text = "cmd[update:1000] date +'%H:%M'";
              color = "rgb(${c palette.fg})";
              font_size = 80;
              font_family = fonts.sans;
              position = "0, 160";
              halign = "center";
              valign = "center";
            }
          ];
        };
      };

      services.playerctld.enable = true;

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

      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "${fonts.mono}:style=Medium:size=9.5";
            pad = "7x7";
            selection-target = "clipboard";
            dpi-aware = "yes";
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
          colors-dark = {
            alpha = "0.95";
            background = c palette.bg;
            foreground = c palette.fg;
            regular0 = c palette.bg;
            regular1 = c palette.redDark;
            regular2 = c palette.greenDark;
            regular3 = c palette.yellowDark;
            regular4 = c palette.blueDark;
            regular5 = c palette.purpleDark;
            regular6 = c palette.aquaDark;
            regular7 = c palette.fg4;
            bright0 = c palette.gray;
            bright1 = c palette.red;
            bright2 = c palette.green;
            bright3 = c palette.yellow;
            bright4 = c palette.blue;
            bright5 = c palette.purple;
            bright6 = c palette.aqua;
            bright7 = c palette.fg;
          };
        };
      };
    };
}
