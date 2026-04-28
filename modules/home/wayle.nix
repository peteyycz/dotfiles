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

      # If primaryMonitors is empty, one wildcard layout. Otherwise an explicit
      # layout per primary connector plus a wildcard hide entry for anything else.
      barLayouts =
        if primaryMonitors == [ ] then
          [ (sections // { monitor = "*"; }) ]
        else
          (map (m: sections // { monitor = m; }) primaryMonitors)
          ++ [
            {
              monitor = "*";
              show = false;
            }
          ];
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
            "background-opacity" = 0;
            rounding = "lg";
            shadow = "none";
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
