{ config, pkgs, lib, ... }:

let
  # Gruvbox Dark colors
  colors = {
    bg = "#282828";
    bgHard = "#1d2021";
    bg1 = "#3c3836";
    bg2 = "#504945";
    bg3 = "#665c54";
    gray = "#928374";
    fg3 = "#bdae93";
    fg4 = "#a89984";
    fg = "#ebdbb2";
    # Normal colors
    red = "#fb4934";
    redDark = "#cc241d";
    green = "#b8bb26";
    greenDark = "#98971a";
    yellow = "#fabd2f";
    yellowDark = "#d79921";
    orange = "#fe8019";
    blue = "#83a598";
    blueDark = "#458588";
    purple = "#d3869b";
    purpleDark = "#b16286";
    aqua = "#8ec07c";
    aquaDark = "#689d6a";
  };

  # Strip # from color for configs that don't want it
  c = color: lib.removePrefix "#" color;

  modifier = "Mod4";
  terminal = "foot";
  menu = "rofi -terminal '${terminal}' -show combi -combi-modes 'drun#run' -modes combi";

  # Workspace names with icons
  ws1 = "1: 󰆍";
  ws2 = "2: 󰊯";
  ws3 = "3: 󰓓";
  ws4 = "4: 󰊗";
  ws9 = "9: 󰒱";
in
{
  home.packages = with pkgs; [
    # Sway and Wayland essentials
    libnotify
    slurp
    wf-recorder
    jq  # Used by tmux-rofi script
    sway-contrib.grimshot
  ];

  wayland.windowManager.sway = {
    enable = true;
    package = pkgs.sway;
    systemd.enable = true;
    checkConfig = false;  # Background uses $HOME which isn't available in sandbox

    config = {
      inherit modifier terminal menu;

      fonts = {
        names = [ "VictorMono Nerd Font" ];
        size = 11.0;
      };

      colors = {
        focused = {
          border = colors.bg3;
          background = colors.bgHard;
          text = colors.fg;
          indicator = colors.orange;
          childBorder = colors.bg3;
        };
        focusedInactive = {
          border = colors.bg1;
          background = colors.bg;
          text = colors.fg3;
          indicator = colors.bg1;
          childBorder = colors.bg1;
        };
        unfocused = {
          border = colors.bg1;
          background = colors.bg;
          text = colors.gray;
          indicator = colors.bg1;
          childBorder = colors.bg1;
        };
        urgent = {
          border = colors.red;
          background = colors.red;
          text = colors.bg;
          indicator = colors.red;
          childBorder = colors.red;
        };
      };

      output = {
        "*" = {
          bg = "$HOME/.local/share/backgrounds/default.jpg fill";
          scale = "1";
        };
      };

      input = {
        "2:7:SynPS/2_Synaptics_TouchPad" = {
          dwt = "enabled";
          tap = "enabled";
          natural_scroll = "enabled";
          middle_emulation = "enabled";
          accel_profile = "adaptive";
          pointer_accel = "0.5";
        };
        "type:keyboard" = {
          xkb_layout = "us,hu";
          xkb_variant = ",qwerty";
          xkb_options = "ctrl:nocaps,grp:alt_shift_toggle";
        };
      };

      floating.modifier = modifier;

      keybindings = lib.mkOptionDefault {
        "${modifier}+Return" = "exec ${terminal}";
        "${modifier}+q" = "kill";
        "${modifier}+d" = "exec ${menu}";
        "${modifier}+Escape" = "exec loginctl lock-session";
        "${modifier}+Shift+c" = "reload";
        "${modifier}+Shift+e" = ''exec "echo -e 'Lock\nLogout\nSuspend\nShutdown\nRestart' | rofi -dmenu -p 'Power' -i | xargs -I {} sh -c 'case {} in Lock) loginctl lock-session;; Logout) swaymsg exit;; Suspend) systemctl suspend;; Shutdown) systemctl poweroff;; Restart) systemctl reboot;; esac'"'';

        # Focus
        "${modifier}+h" = "focus left";
        "${modifier}+j" = "focus down";
        "${modifier}+k" = "focus up";
        "${modifier}+l" = "focus right";
        "${modifier}+Left" = "focus left";
        "${modifier}+Down" = "focus down";
        "${modifier}+Up" = "focus up";
        "${modifier}+Right" = "focus right";

        # Move
        "${modifier}+Shift+h" = "move left";
        "${modifier}+Shift+j" = "move down";
        "${modifier}+Shift+k" = "move up";
        "${modifier}+Shift+l" = "move right";
        "${modifier}+Shift+Left" = "move left";
        "${modifier}+Shift+Down" = "move down";
        "${modifier}+Shift+Up" = "move up";
        "${modifier}+Shift+Right" = "move right";

        # Workspaces
        "${modifier}+1" = "workspace ${ws1}";
        "${modifier}+2" = "workspace ${ws2}";
        "${modifier}+3" = "workspace ${ws3}";
        "${modifier}+4" = "workspace ${ws4}";
        "${modifier}+5" = "workspace number 5";
        "${modifier}+6" = "workspace number 6";
        "${modifier}+7" = "workspace number 7";
        "${modifier}+8" = "workspace number 8";
        "${modifier}+9" = "workspace ${ws9}";
        "${modifier}+0" = "workspace number 10";

        # Move to workspace
        "${modifier}+Shift+1" = "move container to workspace ${ws1}";
        "${modifier}+Shift+2" = "move container to workspace ${ws2}";
        "${modifier}+Shift+3" = "move container to workspace ${ws3}";
        "${modifier}+Shift+4" = "move container to workspace ${ws4}";
        "${modifier}+Shift+5" = "move container to workspace number 5";
        "${modifier}+Shift+6" = "move container to workspace number 6";
        "${modifier}+Shift+7" = "move container to workspace number 7";
        "${modifier}+Shift+8" = "move container to workspace number 8";
        "${modifier}+Shift+9" = "move container to workspace ${ws9}";
        "${modifier}+Shift+0" = "move container to workspace number 10";

        # Layout
        "${modifier}+b" = "splith";
        "${modifier}+v" = "splitv";
        "${modifier}+s" = "layout stacking";
        "${modifier}+w" = "exec tmux-rofi";
        "${modifier}+e" = "layout toggle split";
        "${modifier}+f" = "fullscreen";
        "${modifier}+Shift+f" = "floating toggle";
        "${modifier}+space" = "focus mode_toggle";
        "${modifier}+a" = "focus parent";

        # Scratchpad
        "${modifier}+Shift+minus" = "move scratchpad";
        "${modifier}+minus" = "scratchpad show";

        # Scripts
        "${modifier}+r" = ''exec "find $HOME/Code/src/github.com/peteyycz/scripts -maxdepth 1 -name '*.sh' -printf '%f\n' | sed 's/\.sh$//' | rofi -dmenu -p 'Scripts' -i | xargs -I {} sh -c '$HOME/Code/src/github.com/peteyycz/scripts/{}.sh'"'';

        # Screenshots
        "Print" = "exec grimshot save output";
        "Alt+Print" = "exec grimshot save active";
        "Ctrl+Print" = "exec grimshot copy anything";
        "${modifier}+Print" = ''exec bash -c 'region=$(slurp) && wf-recorder -g "$region" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4' '';
        "${modifier}+Shift+Print" = "exec killall -s SIGINT wf-recorder";
      };

      assigns = {
        "${ws2}" = [{ app_id = "google-chrome"; }];
        "${ws3}" = [{ class = "^Steam$"; }];
        "${ws4}" = [{ class = "^steam_app"; }];
        "${ws9}" = [{ app_id = "com.slack.Slack"; }];
      };

      window.commands = [
        { criteria = { class = "^Steam$"; }; command = "floating enable"; }
        { criteria = { class = "^Steam$"; title = "^Steam$"; }; command = "floating disable"; }
        { criteria = { class = "^steam_app"; }; command = "inhibit_idle focus"; }
        { criteria = { class = ".*"; }; command = "inhibit_idle fullscreen"; }
      ];

      startup = [
        { command = "test -x $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh && $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh"; }
        { command = "${terminal}"; }
        { command = "1password --silent"; }
      ];

      bars = [{
        command = "waybar";
      }];
    };

    extraConfig = ''
      titlebar_padding 8 4
    '';
  };

  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        width = 350;
        height = "(0, 300)";
        origin = "top-right";
        offset = "(10, 10)";
        scale = 0;
        notification_limit = 5;

        progress_bar = true;
        progress_bar_height = 12;
        progress_bar_frame_width = 1;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_corner_radius = 0;
        progress_bar_corners = "all";

        icon_corner_radius = 0;
        icon_corners = "all";

        indicate_hidden = true;
        separator_height = 2;
        padding = 12;
        horizontal_padding = 12;
        text_icon_padding = 12;
        frame_width = 1;
        frame_color = colors.bg1;
        gap_size = 8;
        separator_color = "frame";
        sort = true;

        font = "VictorMono Nerd Font Propo 10";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;

        enable_recursive_icon_lookup = true;
        icon_theme = "Adwaita";
        icon_position = "left";
        min_icon_size = 32;
        max_icon_size = 64;

        sticky_history = true;
        history_length = 20;

        dmenu = "/usr/bin/dmenu -p dunst:";
        browser = "/usr/bin/xdg-open";
        always_run_script = true;
        corner_radius = 0;
        corners = "all";
        ignore_dbusclose = false;
        force_xwayland = false;
        force_xinerama = false;

        mouse_left_click = "do_action, close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };

      experimental = {
        per_monitor_dpi = false;
      };

      urgency_low = {
        background = colors.bgHard;
        foreground = colors.gray;
        frame_color = colors.bg1;
        timeout = 5;
        default_icon = "dialog-information";
      };

      urgency_normal = {
        background = colors.bgHard;
        foreground = colors.fg;
        frame_color = colors.purple;
        timeout = 10;
        override_pause_level = 30;
        default_icon = "dialog-information";
      };

      urgency_critical = {
        background = colors.bgHard;
        foreground = colors.fg;
        frame_color = colors.red;
        timeout = 0;
        override_pause_level = 60;
        default_icon = "dialog-warning";
      };
    };
  };

  programs.rofi = {
    enable = true;
    font = "VictorMono Nerd Font Propo 13";
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
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
        bg = mkLiteral colors.bg;
        bg1 = mkLiteral colors.bg1;
        bg2 = mkLiteral colors.bg2;
        gray = mkLiteral colors.gray;
        fg3 = mkLiteral colors.fg3;
        fg = mkLiteral colors.fg;
        red = mkLiteral colors.red;
        yellow = mkLiteral colors.yellow;
        blue = mkLiteral colors.blue;
        purple = mkLiteral colors.purple;
        aqua = mkLiteral colors.aqua;
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        highlight = mkLiteral "bold ${colors.purple}";
      };
      window = {
        width = mkLiteral "400px";
        background-color = mkLiteral "@bg";
        border = mkLiteral "2px solid";
        border-color = mkLiteral "@bg2";
        border-radius = 0;
      };
      mainbox = {
        padding = mkLiteral "12px";
      };
      inputbar = {
        padding = mkLiteral "8px 12px";
        margin = mkLiteral "0 0 12px 0";
        children = map mkLiteral [ "prompt" "textbox-prompt-colon" "entry" ];
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
        lines = 12;
        columns = 1;
        fixed-height = true;
      };
      element = {
        padding = mkLiteral "4px 12px";
      };
      "element selected" = {
        background-color = mkLiteral "@bg2";
        text-color = mkLiteral "@purple";
      };
      element-icon = {
        size = mkLiteral "20px";
        margin = mkLiteral "0 8px 0 0";
      };
      element-text = {
        vertical-align = mkLiteral "0.5";
      };
    };
  };

  programs.waybar = {
    enable = true;
    settings = [{
      layer = "top";
      position = "top";
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-center = [ "clock" ];
      modules-right = [ "custom/recording" "cpu" "memory" "battery" "sway/language" "custom/dotfiles" "tray" ];

      "custom/dotfiles" = {
        exec = ''cd ~/Code/src/github.com/peteyycz/dotfiles && if [ -n "$(git status --porcelain)" ]; then echo '{"text": "~/.", "tooltip": "Dotfiles have uncommitted changes", "class": "dirty"}'; else echo '{}'; fi'';
        return-type = "json";
        interval = 30;
        on-click = "foot --working-directory=$HOME/Code/src/github.com/peteyycz/dotfiles $SHELL -c 'git status; exec $SHELL'";
      };

      "custom/recording" = {
        exec = ''if pgrep -x wf-recorder > /dev/null; then echo '{"text": "REC", "tooltip": "Click to stop recording", "class": "active"}'; else echo '{}'; fi'';
        return-type = "json";
        interval = 1;
        on-click = "killall -s SIGINT wf-recorder";
      };

      "sway/workspaces" = {
        disable-scroll = true;
      };

      "sway/mode" = {
        format = "{}";
      };

      clock = {
        format = "{:%A (%B %d) %I:%M %p}";
      };

      cpu = {
        format = "󰻠 {usage}%";
        interval = 5;
        states = { warning = 70; critical = 90; };
      };

      memory = {
        format = "󰍛 {percentage}%";
        interval = 10;
        states = { warning = 70; critical = 90; };
      };

      battery = {
        states = { warning = 30; critical = 15; };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-plugged = "󰚥 {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
        tooltip-format = "{timeTo}\n{power}W";
      };

      tray = {
        icon-size = 16;
        spacing = 8;
      };
    }];
    style = ''
      * {
        font-family: "VictorMono Nerd Font Propo";
        font-size: 12pt;
        font-weight: 500;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background: ${colors.bg};
        color: ${colors.fg};
      }

      #waybar > box {
        padding: 4px 4px;
      }

      #workspaces button {
        padding: 4px 8px;
        background: ${colors.bg};
        color: ${colors.gray};
        border: none;
      }

      #workspaces button.visible {
        background: ${colors.bg1};
        color: ${colors.fg};
      }

      #workspaces button.focused {
        background: ${colors.purple};
        color: ${colors.bg};
      }

      #workspaces button.urgent {
        background: ${colors.red};
        color: ${colors.bg};
      }

      #mode {
        background: ${colors.yellow};
        color: ${colors.bg};
        padding: 0 8px;
      }

      #clock {
        color: ${colors.fg};
      }

      #tray {
        padding: 0 8px;
      }

      #tray > .passive {
        -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
        -gtk-icon-effect: highlight;
        background: ${colors.red};
      }

      #custom-dotfiles.dirty {
        color: ${colors.yellow};
        padding: 0 8px;
      }

      #custom-recording.active {
        color: ${colors.bg};
        background: ${colors.red};
        padding: 0 8px;
      }

      #cpu {
        color: ${colors.fg4};
        padding: 0 8px;
      }

      #cpu.warning {
        color: ${colors.yellow};
      }

      #cpu.critical {
        color: ${colors.red};
      }

      #memory {
        color: ${colors.fg4};
        padding: 0 8px;
      }

      #memory.warning {
        color: ${colors.yellow};
      }

      #memory.critical {
        color: ${colors.red};
      }

      #battery {
        color: ${colors.aqua};
        padding: 0 8px;
      }

      #battery.charging {
        color: ${colors.blue};
      }

      #battery.warning:not(.charging) {
        color: ${colors.yellow};
      }

      #battery.critical:not(.charging) {
        color: ${colors.red};
      }

      #language {
        color: ${colors.purple};
        padding: 0 8px;
      }
    '';
  };

  programs.swaylock = {
    enable = true;
    settings = {
      ignore-empty-password = true;
      show-failed-attempts = true;

      color = c colors.bg;

      ring-color = c colors.bg1;
      ring-clear-color = c colors.gray;
      ring-caps-lock-color = c colors.yellow;
      ring-ver-color = c colors.blueDark;
      ring-wrong-color = c colors.red;

      key-hl-color = c colors.blueDark;
      bs-hl-color = c colors.gray;
      caps-lock-key-hl-color = c colors.yellow;
      caps-lock-bs-hl-color = c colors.red;

      inside-color = c colors.bg;
      inside-clear-color = c colors.bg;
      inside-caps-lock-color = c colors.bg;
      inside-ver-color = c colors.bg;
      inside-wrong-color = c colors.bg;

      line-color = c colors.bg;
      line-clear-color = c colors.bg;
      line-caps-lock-color = c colors.bg;
      line-ver-color = c colors.bg;
      line-wrong-color = c colors.bg;

      separator-color = c colors.bg1;

      text-color = c colors.fg;
      text-clear-color = c colors.gray;
      text-caps-lock-color = c colors.yellow;
      text-ver-color = c colors.blueDark;
      text-wrong-color = c colors.red;

      layout-text-color = c colors.fg3;

      indicator-radius = 60;
      indicator-thickness = 20;
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "VictorMono Nerd Font Mono:style=Medium:size=14";
        pad = "7x7";
        selection-target = "clipboard";
      };
      url = {
        launch = "xdg-open \${url}";
      };
      key-bindings = {
        show-urls-launch = "Control+Shift+o";
      };
      colors = {
        alpha = "0.99";
        background = c colors.bg;
        foreground = c colors.fg;
        regular0 = c colors.bg;
        regular1 = c colors.redDark;
        regular2 = c colors.greenDark;
        regular3 = c colors.yellowDark;
        regular4 = c colors.blueDark;
        regular5 = c colors.purpleDark;
        regular6 = c colors.aquaDark;
        regular7 = c colors.fg4;
        bright0 = c colors.gray;
        bright1 = c colors.red;
        bright2 = c colors.green;
        bright3 = c colors.yellow;
        bright4 = c colors.blue;
        bright5 = c colors.purple;
        bright6 = c colors.aqua;
        bright7 = c colors.fg;
      };
    };
  };
}
