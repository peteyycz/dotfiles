{ config, ... }:
let
  fonts = config.fontFamilies;

  # rofi theme matching hare's notched dark glass: borderless translucent tint
  # (frosted by the Hyprland blur layerrule), medium radii, lavender accent on
  # the selected row. `bgA` is the window alpha as a hex byte.
  mkRofiRasi =
    {
      p,
      bgA,
    }:
    ''
      * {
        background-color: transparent;
        text-color:       #${p.fg};
      }

      window {
        width: 640px;
        location: north;
        anchor: north;
        y-offset: 12%;
        background-color: #${p.bg}${bgA};
        border: 0;
        border-radius: 16px;
        padding: 8px;
      }

      mainbox {
        padding: 8px;
        spacing: 10px;
      }

      inputbar {
        padding: 11px 14px;
        margin: 0 0 8px 0;
        background-color: #${p.surface};
        border-radius: 12px;
        spacing: 10px;
        children: [ prompt, entry ];
      }

      prompt {
        text-color: #${p.accent};
        vertical-align: 0.5;
      }

      entry {
        placeholder: "Search…";
        placeholder-color: #${p.subtle};
        text-color: #${p.fg};
      }

      listview {
        lines: 8;
        columns: 1;
        fixed-height: false;
        dynamic: true;
        spacing: 4px;
        scrollbar: false;
      }

      element {
        padding: 8px 12px;
        border-radius: 9px;
        spacing: 10px;
      }

      element selected {
        background-color: #${p.accent};
        text-color: #${p.accentInk};
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
    '';

  # bgA matches the hare bar's translucency (programs.hare bgAlpha 0.30/0.40):
  # 0x4d ≈ 0.30, 0x66 ≈ 0.40. Blur (Hyprland layerrule) does the frosting.
  rofiDark = mkRofiRasi {
    p = config.glassTheme.dark;
    bgA = "4d";
  };
  rofiLight = mkRofiRasi {
    p = config.glassTheme.light;
    bgA = "66";
  };
in
{
  flake.modules.homeManager.apps =
    {
      pkgs,
      lib,
      ...
    }:
    let
      # Points rofi's "glass" theme at the dark or light variant to match hare's
      # current tone (the file hare-tone writes).
      rofiTone = pkgs.writeShellApplication {
        name = "rofi-tone";
        runtimeInputs = [ pkgs.coreutils ];
        text = ''
          state="''${XDG_STATE_HOME:-$HOME/.local/state}/hare/tone"
          tone=dark
          if [ -f "$state" ]; then tone="$(cat "$state")"; fi
          [ "$tone" = light ] || tone=dark
          themes="$HOME/.local/share/rofi/themes"
          mkdir -p "$themes"
          ln -sf "glass-$tone.rasi" "$themes/glass.rasi"
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
        wlogout
        hyprsunset
      ];

      services.playerctld.enable = true;

      # Both tone variants live in rofi's theme search path; rofi-tone symlinks
      # the active one to "glass" (referenced by name below).
      xdg.dataFile."rofi/themes/glass-dark.rasi".text = rofiDark;
      xdg.dataFile."rofi/themes/glass-light.rasi".text = rofiLight;

      systemd.user.services.rofi-tone = {
        Unit = {
          Description = "Match rofi theme to hare's glass tone";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          Type = "oneshot";
          ExecStart = "${rofiTone}/bin/rofi-tone";
        };
      };

      # Re-point rofi whenever hare flips the tone (e.g. on wallpaper change).
      systemd.user.paths.rofi-tone = {
        Unit.Description = "Watch hare tone for rofi";
        Install.WantedBy = [ "graphical-session.target" ];
        Path = {
          PathModified = "%S/hare/tone";
          Unit = "rofi-tone.service";
        };
      };

      # Ensure the "glass" symlink exists right after a switch, not just on login.
      home.activation.rofiTone = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${rofiTone}/bin/rofi-tone || true
      '';

      programs.rofi = {
        enable = true;
        font = "${fonts.sans} 11";
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
          # Gruvbox Material (dark, medium) nudged toward hare: background
          # cooled slightly toward the bar's neutral dark, and magenta swapped
          # for hare's lavender accent so the terminal shares the shell's accent.
          colors = {
            alpha = "0.75";
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
