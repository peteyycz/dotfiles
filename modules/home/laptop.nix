{ ... }:
{
  flake.modules.homeManager.laptop =
    { pkgs, ... }:
    let
      batteryWarn = pkgs.writeShellApplication {
        name = "battery-warn";
        runtimeInputs = with pkgs; [
          libnotify
          coreutils
        ];
        text = ''
          set -uo pipefail

          state_file="''${XDG_RUNTIME_DIR:-/tmp}/battery-warn.state"
          interval=30

          read_battery() {
            for bat in /sys/class/power_supply/BAT*; do
              [ -d "$bat" ] || continue
              cap=$(cat "$bat/capacity" 2>/dev/null || echo "")
              st=$(cat "$bat/status" 2>/dev/null || echo "")
              [ -n "$cap" ] && { echo "$cap $st"; return 0; }
            done
            return 1
          }

          while true; do
            if read -r capacity status < <(read_battery); then
              last=$(cat "$state_file" 2>/dev/null || echo 101)

              if [ "$status" = "Discharging" ]; then
                if [ "$capacity" -le 5 ] && [ "$last" -gt 5 ]; then
                  notify-send -u critical -a battery-warn \
                    "Battery critically low" "Battery at ''${capacity}% — plug in now."
                elif [ "$capacity" -le 10 ] && [ "$last" -gt 10 ]; then
                  notify-send -u normal -a battery-warn \
                    "Battery low" "Battery at ''${capacity}%."
                fi
              fi

              echo "$capacity" > "$state_file"
            fi

            sleep "$interval"
          done
        '';
      };
    in
    {
      # Natural (reverse) scrolling on the built-in touchpad.
      # Device: /proc/bus/input/devices -> "VEN_04F3:00 04F3:31E2 Touchpad".
      programs.plasma.input.touchpads = [
        {
          name = "VEN_04F3:00 04F3:31E2 Touchpad";
          vendorId = "04f3";
          productId = "31e2";
          enable = true;
          naturalScroll = true;
        }
      ];

      systemd.user.services.battery-warn = {
        Unit = {
          Description = "Low-battery desktop notifications";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = "${batteryWarn}/bin/battery-warn";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };
    };
}
