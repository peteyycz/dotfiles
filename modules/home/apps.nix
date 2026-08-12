{ config, ... }:
let
  fonts = config.fontFamilies;

  # Breeze Dark, straight from breeze/share/color-schemes/BreezeDark.colors:
  # Window 32,35,38 / Window alt 41,44,48 / View 20,22,24 / text 252,252,252 /
  # inactive text 161,169,177 / selection 61,174,233.
  breeze = {
    window = "202326";
    windowAlt = "292c30";
    view = "141618";
    fg = "fcfcfc";
    fgInactive = "a1a9b1";
    accent = "3daee9";
    negative = "da4453";
  };

  # rofi theme matching Plasma's Breeze Dark: opaque (KWin does not blur rofi's
  # layer surface, so translucency just muddies it), 1px separator borders and
  # Breeze's small radii, accent-blue selected row.
  breezeRasi = ''
    * {
      background-color: transparent;
      text-color:       #${breeze.fg};
    }

    window {
      width: 640px;
      location: north;
      anchor: north;
      y-offset: 12%;
      background-color: #${breeze.window};
      border: 1px;
      border-color: #${breeze.windowAlt};
      border-radius: 8px;
      padding: 8px;
    }

    mainbox {
      padding: 8px;
      spacing: 8px;
    }

    inputbar {
      padding: 8px 10px;
      margin: 0 0 6px 0;
      background-color: #${breeze.view};
      border: 1px;
      border-color: #${breeze.windowAlt};
      border-radius: 4px;
      spacing: 8px;
      children: [ prompt, entry ];
    }

    prompt {
      text-color: #${breeze.accent};
      vertical-align: 0.5;
    }

    entry {
      placeholder: "Search…";
      placeholder-color: #${breeze.fgInactive};
      text-color: #${breeze.fg};
    }

    listview {
      lines: 8;
      columns: 1;
      fixed-height: false;
      dynamic: true;
      spacing: 2px;
      scrollbar: false;
    }

    element {
      padding: 7px 10px;
      border-radius: 4px;
      spacing: 8px;
    }

    element selected {
      background-color: #${breeze.accent};
      text-color: #${breeze.fg};
    }

    element urgent {
      text-color: #${breeze.negative};
    }

    element-icon {
      size: 18px;
      vertical-align: 0.5;
      text-color: inherit;
    }

    element-text {
      vertical-align: 0.5;
      text-color: inherit;
    }

    message {
      padding: 8px 10px;
      background-color: #${breeze.view};
      border-radius: 4px;
    }

    textbox {
      text-color: #${breeze.fgInactive};
    }
  '';
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
      ];

      xdg.dataFile."rofi/themes/breeze-dark.rasi".text = breezeRasi;

      programs.rofi = {
        enable = true;
        font = "${fonts.sans} 11";
        theme = "breeze-dark";
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
