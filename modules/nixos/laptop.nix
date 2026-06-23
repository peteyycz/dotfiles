{ ... }:
{
  flake.modules.nixos.laptop =
    { pkgs, ... }:
    let
      autoProfile = pkgs.writeShellApplication {
        name = "ppd-auto-profile";
        runtimeInputs = with pkgs; [
          power-profiles-daemon
          coreutils
        ];
        text = ''
          set -uo pipefail

          interval=15
          last=""

          ac_online() {
            for ac in /sys/class/power_supply/AC* /sys/class/power_supply/ADP*; do
              [ -f "$ac/online" ] || continue
              cat "$ac/online"
              return 0
            done
            echo 0
          }

          battery_capacity() {
            for bat in /sys/class/power_supply/BAT*; do
              [ -f "$bat/capacity" ] || continue
              cat "$bat/capacity"
              return 0
            done
            echo 100
          }

          while true; do
            online=$(ac_online)
            capacity=$(battery_capacity)

            if [ "$online" = "1" ]; then
              desired="performance"
            elif [ "$capacity" -le 25 ]; then
              desired="power-saver"
            else
              desired="balanced"
            fi

            if [ "$desired" != "$last" ]; then
              if powerprofilesctl set "$desired"; then
                last="$desired"
                echo "set profile: $desired (ac=$online, cap=$capacity%)"
              fi
            fi

            sleep "$interval"
          done
        '';
      };
    in
    {
      services.power-profiles-daemon.enable = true;
      powerManagement.powertop.enable = true;

      systemd.services.ppd-auto-profile = {
        description = "Switch power profile based on AC + battery level";
        wantedBy = [ "multi-user.target" ];
        after = [ "power-profiles-daemon.service" ];
        requires = [ "power-profiles-daemon.service" ];
        serviceConfig = {
          ExecStart = "${autoProfile}/bin/ppd-auto-profile";
          Restart = "on-failure";
          RestartSec = 5;
        };
      };

      services.pipewire.wireplumber.extraConfig."51-hide-hdmi-audio" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "node.name" = "~alsa_output\\..*HDMI.*"; } ];
            actions.update-props."node.disabled" = true;
          }
        ];
      };

      # Docked (external monitor attached) stays "ignore" so hyprLidHandler can
      # blank eDP-1 without dropping the session.
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend";
        HandleLidSwitchExternalPower = "suspend";
      };
    };
}
