{ ... }:
{
  flake.modules.nixos.fingerprint =
    { pkgs, ... }:
    let
      # Deauthorize the fingerprint reader's USB device while the lid is
      # closed so pam_fprintd sees no readers and PAM (sddm in particular)
      # falls through to password immediately. Masking fprintd doesn't work
      # on NixOS: unit files live in /etc/systemd/system, which outranks the
      # /run/systemd/system symlink that `systemctl --runtime mask` creates,
      # so the mask silently loads as a normal unit.
      fingerprintVendor = "27c6"; # Goodix
      fingerprintProduct = "639c";
      lidToggle = pkgs.writeShellApplication {
        name = "fprintd-lid-toggle";
        runtimeInputs = with pkgs; [ coreutils ];
        text = ''
          set -uo pipefail
          value="$1"
          for d in /sys/bus/usb/devices/*/; do
            [ -r "$d/idVendor" ] && [ -r "$d/idProduct" ] || continue
            [ "$(cat "$d/idVendor")" = "${fingerprintVendor}" ] || continue
            [ "$(cat "$d/idProduct")" = "${fingerprintProduct}" ] || continue
            echo "$value" > "$d/authorized" || true
          done
        '';
      };
      lidEventHandler = pkgs.writeShellApplication {
        name = "fprintd-lid-event";
        runtimeInputs = [ lidToggle ];
        text = ''
          set -uo pipefail
          case "''${1:-}" in
            *close*) fprintd-lid-toggle 0 ;;
            *open*)  fprintd-lid-toggle 1 ;;
          esac
        '';
      };
    in
    {
      services.fprintd.enable = true;
      security.pam.services.sudo.fprintAuth = true;
      security.pam.services.sddm.fprintAuth = true;

      services.acpid = {
        enable = true;
        lidEventCommands = ''
          exec ${lidEventHandler}/bin/fprintd-lid-event "$1"
        '';
      };

      # Cover boot-with-lid-closed: reader is authorized by default after
      # kernel enumeration, so deauthorize before sddm ever calls pam_fprintd.
      systemd.services.fprintd-lid-init = {
        description = "Apply fprintd reader state at boot based on lid state";
        wantedBy = [ "multi-user.target" ];
        before = [ "display-manager.service" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          state=""
          for f in /proc/acpi/button/lid/*/state; do
            [ -r "$f" ] || continue
            state=$(${pkgs.gawk}/bin/awk '{print $2}' "$f")
            break
          done
          if [ "$state" = "closed" ]; then
            ${lidToggle}/bin/fprintd-lid-toggle 0
          fi
        '';
      };
    };
}
