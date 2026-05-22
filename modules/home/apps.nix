{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.apps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      schemePath = "${config.home.homeDirectory}/.local/state/caelestia/scheme.json";
      rofiThemePath = "${config.home.homeDirectory}/.local/state/caelestia/theme/rofi.rasi";
      rofiColorsScript = pkgs.writeShellApplication {
        name = "rofi-caelestia-colors";
        runtimeInputs = with pkgs; [
          jq
          coreutils
        ];
        text = ''
          set -euo pipefail
          out="${rofiThemePath}"
          mkdir -p "$(dirname "$out")"
          [ -f "${schemePath}" ] || exit 0

          read_colour() {
            jq -r ".colours.$1" "${schemePath}"
          }

          bg=$(read_colour surface)
          bg_alt=$(read_colour surfaceContainer)
          fg=$(read_colour onSurface)
          outline=$(read_colour outline)
          accent=$(read_colour primary)
          accent_bg=$(read_colour primaryContainer)

          cat > "$out" <<RASI
          * {
            background-color: transparent;
            text-color:       #$fg;
            highlight:        bold #$accent;
          }

          window {
            width: 720px;
            location: north;
            anchor: north;
            y-offset: 20%;
            background-color: #''${bg}cc;
            border: 0;
            border-radius: 20px;
          }

          mainbox {
            padding: 16px;
          }

          inputbar {
            padding: 14px 18px;
            margin: 0 0 14px 0;
            background-color: #$bg_alt;
            border-radius: 12px;
            children: [ textbox-prompt-colon, entry ];
          }

          prompt {
            text-color: #$accent;
          }

          textbox-prompt-colon {
            expand: false;
            str: " ";
          }

          entry {
            placeholder: "Search...";
            placeholder-color: #$outline;
            text-color: #$fg;
          }

          listview {
            lines: 5;
            columns: 1;
            fixed-height: false;
            dynamic: true;
            spacing: 4px;
          }

          element {
            padding: 9px 14px;
            border-radius: 8px;
            spacing: 10px;
          }

          element selected {
            background-color: #$accent_bg;
            text-color: #$fg;
            border-radius: 8px;
          }

          element-icon {
            size: 24px;
            margin: 0 10px 0 0;
          }

          element-text {
            vertical-align: 0.5;
          }
          RASI
        '';
      };
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
        rofiColorsScript
      ];

      programs.caelestia.cli.settings.theme.postHook = lib.getExe rofiColorsScript;

      home.activation.rofiCaelestiaColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${lib.getExe rofiColorsScript} || true
      '';

      programs.rofi = {
        enable = true;
        font = "${fonts.sans} 13";
        theme = rofiThemePath;
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

      services.playerctld.enable = true;

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
            alpha = "0.95";
          };
        };
      };
    };
}
