{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.wayle =
    {
      config,
      lib,
      theme,
      pkgs,
      ...
    }:
    let
      inherit (theme) palette;
      inherit (config.peteyycz)
        isLaptop
        primaryMonitors
        terminal
        dotfilesDir
        ;

      # Wayle registers its NetworkManager client once at startup and drops the
      # network module for the whole session if NM isn't on the system bus yet.
      # On this machine wayle.service wins the race against NetworkManager.service
      # by ~1s, so we block startup until the bus name is visible.
      waitForNM = pkgs.writeShellScript "wayle-wait-for-nm" ''
        for _ in $(seq 1 50); do
          if ${pkgs.systemd}/bin/busctl --system --no-pager status org.freedesktop.NetworkManager >/dev/null 2>&1; then
            exit 0
          fi
          sleep 0.2
        done
        exit 0  # give up quietly after 10s; wayle will start without network
      '';

      sections = {
        left = [
          "dashboard"
          "hyprland-workspaces"
          "window-title"
          "media"
        ];
        center = [ "clock" ];
        right = [
          "custom-recording"
          "volume"
          "bluetooth"
          "network"
        ]
        ++ lib.optionals isLaptop [
          "battery"
        ]
        ++ [
          "keyboard-input"
          "custom-dotfiles"
          "notifications"
        ];
      };

      # Wayle's static layout can't pick one monitor when several primaries are
      # connected at once (e.g. DP-1 + HDMI-A-1 docked). Render on every output;
      # `wayle-primary-bar` below uses `wayle panel show/hide` at runtime to keep
      # the bar on the highest-priority connected monitor.
      barLayouts = [ (sections // { monitor = "*"; }) ];

      waylePrimaryBar = pkgs.writeShellApplication {
        name = "wayle-primary-bar";
        runtimeInputs = with pkgs; [
          jq
          socat
          hyprland
          coreutils
          wayle
        ];
        text = ''
          set -uo pipefail

          priority=("$@")
          socket="$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock"

          apply() {
            local monitors primary="" name
            monitors=$(hyprctl monitors -j 2>/dev/null) || return 0

            for m in "''${priority[@]}"; do
              if jq -e --arg n "$m" 'map(select(.name == $n)) | length > 0' <<<"$monitors" >/dev/null; then
                primary="$m"
                break
              fi
            done

            while IFS= read -r name; do
              if [[ "$name" == "$primary" ]]; then
                wayle panel show "$name" >/dev/null 2>&1 || true
              else
                wayle panel hide "$name" >/dev/null 2>&1 || true
              fi
            done < <(jq -r '.[] | .name' <<<"$monitors")
          }

          for _ in $(seq 1 60); do
            wayle panel status >/dev/null 2>&1 && break
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
      services.wayle = {
        enable = true;
        settings = {
          general = {
            "font-sans" = fonts.sans;
            "font-mono" = fonts.mono;
          };

          bar = {
            layout = barLayouts;

            # Floating, transparent, pill-buttoned — approximates the HyprPanel theme.
            "inset-edge" = 0.5;
            "inset-ends" = 0.5;
            "background-opacity" = 55;
            rounding = "full";
            shadow = "drop";
            "button-rounding" = "full";
            "button-border-location" = "all";
            "button-border-width" = 1;
            "button-bg-opacity" = 85;
            "button-group-border-location" = "none";
            # Uniform pill (no colored icon-prefix block); icon + label share one color per module.
            "button-variant" = "basic";
            "button-label-weight" = "medium";
            "button-label-padding" = 1.5;
            "button-icon-size" = 0.8;
          };

          modules = {
            dashboard = {
              "icon-color" = "yellow";
            };

            window-title = {
              "icon-color" = "accent";
              "label-color" = "accent";
              "label-max-length" = 20;
            };

            clock = {
              format = "%a %d %b  %H:%M";
              "icon-color" = "accent";
            };

            network = {
              "label-max-length" = 12;
              "icon-color" = "accent";
            };

            bluetooth = {
              "icon-color" = "blue";
            };

            volume = {
              "icon-color" = "accent";
              "label-color" = "accent";
            };

            notifications = {
              "icon-color" = "green";
            };

            keyboard-input = {
              "icon-color" = "yellow";
              "layout-alias-map" = {
                "English (US)" = "US";
                "Hungarian (QWERTY)" = "HU";
                "Hungarian" = "HU";
              };
              "left-click" = "hyprctl switchxkblayout all next";
            };

            media = {
              "label-max-length" = 40;
              "icon-color" = "blue";
            };

            hyprland-workspaces = {
              "app-icons-show" = true;
              "app-icon-map" = {
                "title:*Microsoft Teams*" = "ld-message-circle-symbolic";
              };
              "workspace-padding" = 0.5;
              "monitor-specific" = false;
              "icon-size" = 0.8;
            };

            custom = lib.mapAttrsToList (
              id: attrs:
              {
                inherit id;
                "icon-color" = "red";
                "label-color" = "red";
              }
              // attrs
            ) config.peteyycz.wayleCustomModules;
          }
          // lib.optionalAttrs isLaptop {
            battery = {
              "label-show" = true;
              "icon-color" = "yellow";
            };
          };

          styling = {
            "theme-provider" = "wayle";
            rounding = "lg";
            palette = {
              bg = palette.bgHard;
              surface = palette.bg;
              elevated = palette.bg1;
              fg = palette.fg;
              "fg-muted" = palette.fg4;
              primary = palette.orange;
              red = palette.red;
              yellow = palette.yellow;
              green = palette.green;
              blue = palette.blue;
            };
          };
        };
      };

      systemd.user.services.wayle.Service.ExecStartPre = [ "${waitForNM}" ];

      systemd.user.services.wayle-primary-bar = lib.mkIf (primaryMonitors != [ ]) {
        Unit = {
          Description = "Pin wayle bar to the highest-priority connected monitor";
          PartOf = [ "graphical-session.target" ];
          After = [
            "graphical-session.target"
            "wayle.service"
          ];
          Requires = [ "wayle.service" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = "${waylePrimaryBar}/bin/wayle-primary-bar ${lib.escapeShellArgs primaryMonitors}";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };

      peteyycz.wayleCustomModules = {
        dotfiles = {
          icon = "󰊢";
          format = "󰊢";
          command = "bash -c 'cd ${dotfilesDir} && if [ -n \"$(git status --porcelain)\" ]; then echo 1; fi'";
          "interval-ms" = 30000;
          "hide-if-empty" = true;
          "left-click" = "${terminal} --working-directory=${dotfilesDir} $SHELL -c 'git status; exec $SHELL'";
        };
        recording = {
          format = "󰻂 {{ output }}";
          command = "bash -c 'pgrep -x wf-recorder >/dev/null && echo REC || echo \"\"'";
          "interval-ms" = 2000;
          "hide-if-empty" = true;
          "left-click" = "pkill -SIGINT -x wf-recorder";
        };
      };
    };
}
