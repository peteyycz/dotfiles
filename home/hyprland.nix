{ config, pkgs, lib, isLaptop, ... }:

let
  colorsLib = import ./colors.nix { inherit lib; };
  colors = colorsLib.palette;
  inherit (colorsLib) c;

  terminal = "foot";
  menu = "rofi -terminal '${terminal}' -show drun";

  hyprAutoScale = pkgs.writeShellApplication {
    name = "hypr-auto-scale";
    runtimeInputs = with pkgs; [ jq socat hyprland coreutils gawk ];
    text = ''
      set -uo pipefail

      socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

      apply() {
        local monitors name w h pw ph current scale pos
        monitors=$(hyprctl monitors -j 2>/dev/null) || return 0

        while IFS=$'\t' read -r name w h pw ph current; do
          case "$name" in
            eDP-1)
              scale="1.0"
              pos="0x0"
              ;;
            *)
              if [[ "$pw" -gt 0 && "$ph" -gt 0 ]]; then
                scale=$(awk -v w="$w" -v h="$h" -v pw="$pw" -v ph="$ph" 'BEGIN {
                  diag_px = sqrt(w*w + h*h);
                  diag_in = sqrt(pw*pw + ph*ph) / 25.4;
                  dpi = diag_px / diag_in;
                  if (dpi < 110) print "1.0";
                  else if (dpi < 130) print "1.25";
                  else if (dpi < 170) print "1.5";
                  else if (dpi < 200) print "1.75";
                  else print "2.0";
                }')
              else
                scale="1.0"
              fi
              pos="auto-up"
              ;;
          esac

          if awk -v a="$current" -v b="$scale" 'BEGIN { exit !(sqrt((a-b)^2) < 0.01) }'; then
            continue
          fi

          hyprctl keyword monitor "$name,preferred,$pos,$scale" >/dev/null
        done < <(jq -r '.[] | "\(.name)\t\(.width)\t\(.height)\t\(.physicalWidth)\t\(.physicalHeight)\t\(.scale)"' <<<"$monitors")
      }

      for _ in $(seq 1 60); do
        hyprctl monitors >/dev/null 2>&1 && break
        sleep 0.5
      done

      apply

      socat -U - UNIX-CONNECT:"$socket" | while IFS= read -r line; do
        case "$line" in
          monitoradded*|monitorremoved*|configreloaded*)
            sleep 0.4
            apply
            ;;
        esac
      done
    '';
  };

in
{
  options.peteyycz = {
    hyprlandExtraBinds = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
    hyprlandExtraWindowRules = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
    };
  };

  config = {

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${config.home.homeDirectory}/.local/share/backgrounds/default.jpg" ];
      wallpaper = [{
        monitor = "";
        path = "${config.home.homeDirectory}/.local/share/backgrounds/default.jpg";
        fit_mode = "cover";
      }];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$term" = terminal;
      "$menu" = menu;

      monitor = lib.optionals isLaptop [ "eDP-1,preferred,0x0,1" ]
        ++ [ ",preferred,auto-up,1" ];

      workspace = lib.optionals isLaptop
        (map (n: "${toString n}, monitor:eDP-1") (lib.range 1 10));

      exec-once = [
        "test -x $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh && $HOME/Code/src/github.com/peteyycz/scripts/@peteyycz:dev-start.sh"
        "sleep 0.5 && hyprctl dispatch workspace 1 && ${terminal}"
        "1password --silent"
        "google-chrome-stable"
        "slack"
        "spotify"
      ];

      input = {
        kb_layout = "us,hu";
        kb_variant = ",qwerty";
        kb_options = "ctrl:nocaps,grp:alt_shift_toggle";
        follow_mouse = 1;
        sensitivity = 0.5;
        accel_profile = "adaptive";
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
          disable_while_typing = true;
          middle_button_emulation = true;
        };
      };

      general = {
        gaps_in = 8;
        gaps_out = 12;
        border_size = 0;
        "col.active_border" = "rgb(${c colors.bgHard})";
        "col.inactive_border" = "rgb(${c colors.bg})";
        layout = "dwindle";
      };

      decoration = {
        rounding = 12;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
        };
        shadow = {
          enabled = true;
          range = 20;
          render_power = 3;
          offset = "0 5";
          color = "rgba(0000007F)";
        };
        dim_inactive = true;
        dim_strength = 0.15;
      };

      animations = {
        enabled = true;
        bezier = [
          "overshot, 0.05, 0.9, 0.1, 1.1"
          "smoothOut, 0.36, 0, 0.66, -0.56"
          "smoothIn, 0.25, 1, 0.5, 1"
        ];
        animation = [
          "windows, 1, 3, overshot, popin 80%"
          "windowsOut, 1, 2, smoothOut, popin 80%"
          "windowsMove, 1, 2, default"
          "border, 1, 6, default"
          "fade, 1, 3, smoothIn"
          "workspaces, 1, 3, smoothIn, slide"
          "layers, 1, 3, overshot, popin 80%"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
      };

      layerrule = [
        "blur on, match:namespace ^(rofi)$"
        "ignore_alpha 0.5, match:namespace ^(rofi)$"
        "blur on, match:namespace ^(wayle.*)$"
        "ignore_alpha 0.5, match:namespace ^(wayle.*)$"
      ];

      windowrule = [
        "workspace 2 silent, match:class ^(google-chrome)$"
        "workspace 3 silent, match:class ^(Steam)$"
        "workspace 4 silent, match:class ^(steam_app)"
        "workspace 7 silent, match:class ^(spotify)$"
        "workspace 9 silent, match:class ^(Slack)$"

        "float on, match:class ^(Steam)$"
        "tile on, match:class ^(Steam)$, match:title ^(Steam)$"
        "idle_inhibit focus, match:class ^(steam_app)"
        "idle_inhibit fullscreen, match:fullscreen 1"
        "float on, match:class ^(org\\.gnome\\.Nautilus)$"
        "float on, match:class ^(imv)$"
        "float on, match:class ^(mpv)$"
        "float on, match:class ^(org\\.gnome\\.NautilusPreviewer)$"
      ] ++ config.peteyycz.hyprlandExtraWindowRules;

      bind = [
        "$mod, Return, exec, $term"
        "$mod, Q, killactive"
        "$mod, D, exec, $menu"
        "$mod, Escape, exec, loginctl lock-session"
        "$mod SHIFT, C, exec, hyprctl reload"
        "$mod SHIFT, E, exec, echo -e 'Lock\\nLogout\\nSuspend\\nShutdown\\nReboot' | rofi -dmenu -p 'Power' -i | xargs -I {} sh -c 'case {} in Lock) loginctl lock-session;; Logout) hyprctl dispatch exit;; Suspend) systemctl suspend;; Shutdown) systemctl poweroff;; Reboot) systemctl reboot;; esac'"

        "$mod, H, movefocus, l"
        "$mod, J, movefocus, d"
        "$mod, K, movefocus, u"
        "$mod, L, movefocus, r"
        "$mod, left, movefocus, l"
        "$mod, down, movefocus, d"
        "$mod, up, movefocus, u"
        "$mod, right, movefocus, r"

        "$mod SHIFT, H, movewindow, l"
        "$mod SHIFT, J, movewindow, d"
        "$mod SHIFT, K, movewindow, u"
        "$mod SHIFT, L, movewindow, r"
        "$mod SHIFT, left, movewindow, l"
        "$mod SHIFT, down, movewindow, d"
        "$mod SHIFT, up, movewindow, u"
        "$mod SHIFT, right, movewindow, r"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        "$mod SHIFT, M, movecurrentworkspacetomonitor, +1"

        "$mod, B, togglesplit"
        "$mod, V, togglesplit"
        "$mod, C, exec, caldy toggle"
        "$mod, W, exec, tmux-rofi"
        "$mod, E, togglesplit"
        "$mod, F, fullscreen, 0"
        "$mod SHIFT, F, togglefloating"
        "$mod, space, togglefloating"
        "$mod, A, movefocus, u"

        "$mod SHIFT, minus, movetoworkspacesilent, special:scratch"
        "$mod, minus, togglespecialworkspace, scratch"

        "$mod, R, exec, find $HOME/Code/src/github.com/peteyycz/scripts -maxdepth 1 -name '*.sh' -printf '%f\\n' | sed 's/\\.sh$//' | rofi -dmenu -p 'Scripts' -i | xargs -I {} sh -c '$HOME/Code/src/github.com/peteyycz/scripts/{}.sh'"

        ", Print, exec, grimblast save output"
        "ALT, Print, exec, grimblast save active"
        "CTRL, Print, exec, grimblast copy area"
        ''$mod, Print, exec, bash -c 'region=$(slurp) && wf-recorder -g "$region" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4' ''
        "$mod SHIFT, Print, exec, pkill -SIGINT -x wf-recorder"
      ] ++ config.peteyycz.hyprlandExtraBinds;

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      bindle = [
        ", XF86AudioLowerVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
        ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  systemd.user.services.hypr-auto-scale = {
    Unit = {
      Description = "Auto-scale Hyprland monitors based on DPI";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
    Service = {
      ExecStart = "${hyprAutoScale}/bin/hypr-auto-scale";
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  };
}
