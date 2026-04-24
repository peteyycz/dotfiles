{ config, pkgs, lib, isLaptop, primaryMonitors ? [ ], ... }:

let
  colorsLib = import ./colors.nix { inherit lib; };
  colors = colorsLib.palette;

  terminal = "foot";

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
    left = [ "dashboard" "hyprland-workspaces" "window-title" "media" ];
    center = [ "clock" ];
    right = [
      "custom-recording"
      "custom-todos"
      "volume"
      "bluetooth"
      "network"
    ] ++ lib.optionals isLaptop [
      "battery"
    ] ++ [
      "keyboard-input"
      "custom-dotfiles"
      "notifications"
    ];
  };

  # If primaryMonitors is empty, one wildcard layout. Otherwise an explicit
  # layout per primary connector plus a wildcard hide entry for anything else.
  barLayouts =
    if primaryMonitors == [ ]
    then [ (sections // { monitor = "*"; }) ]
    else
      (map (m: sections // { monitor = m; }) primaryMonitors)
      ++ [ { monitor = "*"; show = false; } ];
in
{
  options.peteyycz = {
    wayleCustomModules = lib.mkOption {
      type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
      default = { };
      description = ''
        Keyed by custom module id. Value is the Wayle custom-module config
        without the `id` field (id is injected from the attribute name).
      '';
    };
  };

  config = {
    services.wayle = {
      enable = true;
      settings = {
        bar = {
          layout = barLayouts;

          # Floating, transparent, pill-buttoned — approximates the HyprPanel theme.
          "inset-edge" = 0.5;
          "inset-ends" = 0.5;
          "background-opacity" = 0;
          rounding = "lg";
          shadow = "none";
          "button-rounding" = "full";
          "button-border-location" = "none";
          "button-group-border-location" = "none";
        };

        modules = {
          clock = {
            format = "%a %d %b  %H:%M";
            "left-click" = "${terminal} -e cal -3";
          };

          network = {
            "label-max-length" = 12;
            "left-click" = "${terminal} -e nmtui";
          };

          media = {
            "label-max-length" = 40;
          };

          hyprland-workspaces = {
            "min-workspace-count" = 10;
          };

          custom = lib.mapAttrsToList
            (id: attrs: { inherit id; } // attrs)
            config.peteyycz.wayleCustomModules;
        } // lib.optionalAttrs isLaptop {
          battery = {
            "label-show" = true;
          };
        };

        styling = {
          "theme-provider" = "wayle";
          rounding = "lg";
          palette = {
            bg = colors.bgHard;
            surface = colors.bg;
            elevated = colors.bg1;
            fg = colors.fg;
            "fg-muted" = colors.fg4;
            primary = colors.orange;
            red = colors.red;
            yellow = colors.yellow;
            green = colors.green;
            blue = colors.blue;
          };
        };
      };
    };

    systemd.user.services.wayle.Service.ExecStartPre = [ "${waitForNM}" ];

    peteyycz.wayleCustomModules = {
      dotfiles = {
        format = "󰊢";
        command = "bash -c 'cd ~/Code/src/github.com/peteyycz/nixos-config && if [ -n \"$(git status --porcelain)\" ]; then echo 1; fi'";
        "interval-ms" = 30000;
        "hide-if-empty" = true;
        "left-click" = "${terminal} --working-directory=$HOME/Code/src/github.com/peteyycz/nixos-config $SHELL -c 'git status; exec $SHELL'";
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
