{ ... }:
{
  flake.modules.homeManager.hyprland =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (config.peteyycz) isLaptop terminal scriptsDir;

      # When the lid closes with at least one non-eDP-1 monitor connected,
      # migrate any workspaces still on eDP-1 to the external monitor and then
      # disable eDP-1. Workspaces 1..10 are pinned to eDP-1 via the `workspace`
      # rule, so hyprland will not auto-migrate them when the panel drops —
      # they must be moved explicitly. On lid open, re-enable eDP-1.
      #
      # Skip while hyprlock is running: hyprlock 0.9.4 asserts on a wl_output
      # add/remove during its lifetime (hyprlock.cpp:380 "Disconnected from
      # pollfd id 0"), which dumps core and drops the seat to a TTY.
      hyprLidHandler = pkgs.writeShellApplication {
        name = "hypr-lid-handler";
        runtimeInputs = with pkgs; [
          jq
          hyprland
          procps
          coreutils
          gawk
        ];
        text = ''
          set -uo pipefail

          action="''${1:-}"

          if pgrep -x hyprlock >/dev/null; then
            exit 0
          fi

          case "$action" in
            close)
              monitors=$(hyprctl monitors -j 2>/dev/null) || exit 0
              external=$(jq -r '.[] | select(.name != "eDP-1") | .name' <<<"$monitors" | head -n1)
              if [[ -n "$external" ]]; then
                while IFS= read -r ws; do
                  [[ -n "$ws" ]] || continue
                  hyprctl dispatch moveworkspacetomonitor "$ws $external" >/dev/null
                done < <(hyprctl workspaces -j 2>/dev/null | jq -r '.[] | select(.monitor == "eDP-1") | .id')
                hyprctl keyword monitor "eDP-1,disable" >/dev/null
              fi
              ;;
            open)
              hyprctl keyword monitor "eDP-1,preferred,0x0,1" >/dev/null
              ;;
            sync)
              # Reconcile with current lid position. Config reload
              # (nixos-rebuild switch) re-applies the static monitor +
              # workspace-pin rules, which resurrect eDP-1 and drag
              # workspaces back onto it even when the lid is shut. Read
              # the ACPI lid state and rerun the close branch if needed.
              state=""
              for f in /proc/acpi/button/lid/*/state; do
                [[ -r "$f" ]] || continue
                state=$(awk '{print $2}' "$f")
                break
              done
              [[ "$state" == "closed" ]] && exec "$0" close
              ;;
          esac
        '';
      };

      screenshot = pkgs.writeShellApplication {
        name = "screenshot";
        runtimeInputs = with pkgs; [
          grimblast
          libnotify
          coreutils
          pipewire
        ];
        text = ''
          set -uo pipefail
          dir="$HOME/Screenshots"
          mkdir -p "$dir"
          file="$dir/$(date +%F.%H-%M-%S).png"
          pw-play ${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/camera-shutter.oga >/dev/null 2>&1 &
          grimblast --notify save output "$file"
        '';
      };

      hyprAutoScale = pkgs.writeShellApplication {
        name = "hypr-auto-scale";
        runtimeInputs = with pkgs; [
          jq
          socat
          hyprland
          coreutils
          gawk
        ];
        text = ''
          set -uo pipefail

          socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

          apply() {
            local monitors name w h pw ph cur_scale cur_rate modes scale pos rate mode changed=0
            monitors=$(hyprctl monitors -j 2>/dev/null) || return 0

            while IFS=$'\t' read -r name w h pw ph cur_scale cur_rate modes; do
              if [[ "$pw" -gt 0 && "$ph" -gt 0 ]]; then
                # Tiered DPI buckets rather than linear DPI/ref + round: the
                # 0.25 scale step is wide relative to common panel densities,
                # so a 24" 1440p panel (~122 DPI) and a 14" 1200p panel
                # (~162 DPI) live on opposite sides of any single rounding
                # threshold even though both want 1.25. Buckets chosen so
                # 24" 1080p (~92) stays at 1.0, the broad "comfortable
                # hi-DPI" band (24" 1440p, 14"–27" 1440p+, 27" 4K, etc.)
                # lands on 1.25, and true retina densities step up cleanly.
                scale=$(awk -v w="$w" -v h="$h" -v pw="$pw" -v ph="$ph" 'BEGIN {
                  diag_px = sqrt(w*w + h*h);
                  diag_in = sqrt(pw*pw + ph*ph) / 25.4;
                  dpi = diag_px / diag_in;
                  if      (dpi < 100) s = 1.00;
                  else if (dpi < 180) s = 1.25;
                  else if (dpi < 240) s = 1.50;
                  else if (dpi < 320) s = 1.75;
                  else                s = 2.00;
                  printf "%.2f", s;
                }')
              else
                scale="1.0"
              fi

              case "$name" in
                eDP-1) pos="0x0" ;;
                *) pos="auto-up" ;;
              esac

              rate=$(awk -v w="$w" -v h="$h" -v modes="$modes" 'BEGIN {
                n = split(modes, arr, ",");
                best = 0;
                target = w "x" h "@";
                for (i = 1; i <= n; i++) {
                  if (index(arr[i], target) == 1) {
                    r = substr(arr[i], length(target) + 1);
                    sub(/Hz$/, "", r);
                    if (r + 0 > best) best = r + 0;
                  }
                }
                if (best > 0) printf "%.2f", best;
              }')

              if [[ -n "$rate" ]]; then
                mode="''${w}x''${h}@''${rate}"
              else
                mode="preferred"
              fi

              # Quickshell (hare) honors the compositor scale, so no per-monitor
              # overlay is needed — just set the hyprctl scale below.
              if awk -v a="$cur_scale" -v b="$scale" -v ra="$cur_rate" -v rb="$rate" \
                'BEGIN { exit !(sqrt((a-b)^2) < 0.01 && (rb == "" || sqrt((ra-rb)^2) < 0.5)) }'; then
                continue
              fi

              hyprctl keyword monitor "$name,$mode,$pos,$scale" >/dev/null
              changed=1
            done < <(jq -r '.[] | "\(.name)\t\(.width)\t\(.height)\t\(.physicalWidth)\t\(.physicalHeight)\t\(.scale)\t\(.refreshRate)\t\(.availableModes | join(","))"' <<<"$monitors")

            # awww (swww) caches its buffer scale from wl_output at startup and
            # gets stuck if hyprctl changes the monitor scale afterwards —
            # bounce it so it re-allocates at the new scale.
            if [[ "$changed" -eq 1 ]]; then
              systemctl --user try-restart wallpaper.service 2>/dev/null || true
            fi
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
                ${hyprLidHandler}/bin/hypr-lid-handler sync
                ;;
            esac
          done
        '';
      };
    in
    {
      wayland.windowManager.hyprland = {
        enable = true;
        package = null;
        portalPackage = null;
        systemd.enable = true;
        configType = "hyprlang";

        settings = {
          "$mod" = "SUPER";
          "$term" = terminal;

          monitor = lib.optionals isLaptop [ "eDP-1,preferred,0x0,1" ] ++ [ ",preferred,auto-up,1" ];

          workspace = lib.optionals isLaptop (map (n: "${toString n}, monitor:eDP-1") (lib.range 1 10));

          exec-once = [
            "test -x ${scriptsDir}/@peteyycz:dev-start.sh && ${scriptsDir}/@peteyycz:dev-start.sh"
            "1password --silent"
            "google-chrome-stable"
            "slack --startup"
          ]
          ++ config.peteyycz.hyprlandExtraExecOnce;

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
            layout = "dwindle";
          };

          decoration = {
            rounding = 12;
            blur = {
              enabled = true;
              size = 6;
              passes = 2;
              vibrancy = 0.17;
              new_optimizations = true;
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
            preserve_split = true;
          };

          gesture = [ "3, horizontal, workspace" ];

          misc = {
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            focus_on_activate = true;
          };

          # XWayland clients can't render at fractional scales — without this
          # the compositor renders them at scale=1 and bilinearly upscales,
          # which blurs Wine games (Battle.net, WoW) on a 1.25x monitor.
          xwayland.force_zero_scaling = true;

          layerrule = [
            "blur on, match:namespace ^(rofi)$"
            "ignore_alpha 0.2, match:namespace ^(rofi)$"
            "blur on, match:namespace ^(hare)$"
            "ignore_alpha 0.2, match:namespace ^(hare)$"
            "blur on, match:namespace ^(wlogout)$"
          ];

          windowrule = [
            "workspace 2 silent, match:class ^(google-chrome)$"
            "workspace 3 silent, match:class ^([Ss]team)$"
            "workspace 3 silent, match:class ^(Slack)$, match:initial_title ^(Slack)$"
            "workspace 4 silent, match:class ^(steam_app)"
            "workspace 4 silent, match:title ^(.*Microsoft Teams.*)$"

            "float on, match:class ^([Ss]team)$"
            "tile on, match:class ^([Ss]team)$, match:title ^(Steam)$"
            "idle_inhibit focus, match:class ^(steam_app)"
            "idle_inhibit fullscreen, match:fullscreen 1"
            "float on, match:class ^(org\\.gnome\\.Nautilus)$"
            "float on, match:class ^(imv)$"
            "float on, match:class ^(vlc)$"
            "float on, match:class ^(org\\.gnome\\.NautilusPreviewer)$"

            # Slack subwindows (calls, huddles, screen-share controls) float;
            # main Slack window keeps default tiling.
            "float on, match:class ^(Slack)$, match:title ^(Slack \\|.*)$"
            "float on, match:class ^(Slack)$, match:title ^(.*[Hh]uddle.*)$"
          ]
          ++ config.peteyycz.hyprlandExtraWindowRules;

          bind = [
            "$mod, Return, exec, $term"
            "$mod, Q, killactive"
            "$mod, D, exec, rofi -show drun"
            "$mod, Escape, exec, loginctl lock-session"
            "$mod, C, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            "$mod SHIFT, C, exec, hyprctl reload"
            "$mod SHIFT, E, exec, wlogout"

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

            "$mod, B, layoutmsg, togglesplit"
            "$mod, V, layoutmsg, togglesplit"
            "$mod, W, exec, tmux-rofi"
            "$mod SHIFT, W, exec, tmuxw-rofi"
            "$mod CTRL, W, exec, tmuxw-close"
            "$mod, E, layoutmsg, togglesplit"
            "$mod, F, fullscreen, 0"
            "$mod SHIFT, F, togglefloating"
            "$mod, space, togglefloating"
            "$mod, A, movefocus, u"

            "$mod SHIFT, minus, movetoworkspacesilent, special:scratch"
            "$mod, minus, togglespecialworkspace, scratch"

            "$mod, R, exec, find ${scriptsDir} -maxdepth 1 -name '*.sh' -printf '%f\\n' | sed 's/\\.sh$//' | rofi -dmenu -p 'Scripts' -i | xargs -I {} sh -c '${scriptsDir}/{}.sh'"

            ", Print, exec, ${screenshot}/bin/screenshot"
            "ALT, Print, exec, grimblast save active"
            "CTRL, Print, exec, grimblast copy area"
            ''$mod, Print, exec, bash -c 'region=$(slurp) && wf-recorder -g "$region" -f ~/Videos/recording-$(date +%Y%m%d-%H%M%S).mp4' ''
            "$mod SHIFT, Print, exec, pkill -SIGINT -x wf-recorder"
          ]
          ++ config.peteyycz.hyprlandExtraBinds;

          bindl = [
            ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
          ]
          ++ lib.optionals isLaptop [
            ", switch:on:Lid Switch, exec, ${hyprLidHandler}/bin/hypr-lid-handler close"
            ", switch:off:Lid Switch, exec, ${hyprLidHandler}/bin/hypr-lid-handler open"
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
