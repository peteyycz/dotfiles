{ config, ... }:
let
  fonts = config.fontFamilies;
  glass = config.glassTheme.dark;
in
{
  flake.modules.homeManager.apps =
    {
      pkgs,
      ...
    }:
    let
      # Static dark-glass rofi theme. Translucent surfaces get frosted by the
      # Hyprland `blur, namespace:rofi` layerrule.
      rofiRasi = ''
        * {
          background-color: transparent;
          text-color:       #${glass.fg};
        }

        window {
          width: 720px;
          location: north;
          anchor: north;
          y-offset: 18%;
          background-color: #${glass.bg}cc;
          border: 1px;
          border-color: #${glass.border}1a;
          border-radius: 18px;
        }

        mainbox {
          padding: 16px;
        }

        inputbar {
          padding: 14px 18px;
          margin: 0 0 14px 0;
          background-color: #${glass.surface}cc;
          border-radius: 12px;
          children: [ textbox-prompt-colon, entry ];
        }

        prompt {
          text-color: #${glass.accent};
        }

        textbox-prompt-colon {
          expand: false;
          str: " ";
        }

        entry {
          placeholder: "Search...";
          placeholder-color: #${glass.subtle};
          text-color: #${glass.fg};
        }

        listview {
          lines: 6;
          columns: 1;
          fixed-height: false;
          dynamic: true;
          spacing: 4px;
        }

        element {
          padding: 9px 14px;
          border-radius: 10px;
          spacing: 10px;
        }

        element selected {
          background-color: #${glass.surface};
          text-color: #${glass.fg};
        }

        element-icon {
          size: 22px;
          margin: 0 10px 0 0;
        }

        element-text {
          vertical-align: 0.5;
        }
      '';
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
        papirus-icon-theme
        wlogout
      ];

      services.playerctld.enable = true;

      # Written into rofi's theme search path; referenced by name below.
      xdg.dataFile."rofi/themes/glass.rasi".text = rofiRasi;

      programs.rofi = {
        enable = true;
        font = "${fonts.sans} 13";
        theme = "glass";
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
      };

      programs.foot = {
        enable = true;
        settings = {
          main = {
            font = "${fonts.mono}:style=Medium:size=8.5";
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
          colors = {
            alpha = "0.9";
            background = glass.bg;
            foreground = glass.fg;
            regular0 = "27272a";
            regular1 = "f87171";
            regular2 = "a3be8c";
            regular3 = "ebcb8b";
            regular4 = "81a1c1";
            regular5 = "b48ead";
            regular6 = "88c0d0";
            regular7 = "d4d4d8";
            bright0 = "3f3f46";
            bright1 = "fca5a5";
            bright2 = "c0d6a6";
            bright3 = "f5dea0";
            bright4 = "a3c0e0";
            bright5 = "cba0c4";
            bright6 = "a8d8e0";
            bright7 = "fafafa";
          };
        };
      };
    };
}
