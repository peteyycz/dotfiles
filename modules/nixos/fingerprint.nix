{ ... }:
{
  flake.modules.nixos.fingerprint =
    { pkgs, ... }:
    let
      # Deauthorize the fingerprint reader's USB device while the lid is
      # closed so pam_fprintd sees no readers and PAM (the lockscreen in
      # particular, when docked with the lid shut and the reader physically
      # out of reach) falls through to password immediately. Masking fprintd
      # doesn't work on NixOS: unit files live in /etc/systemd/system, which
      # outranks the /run/systemd/system symlink that `systemctl --runtime
      # mask` creates, so the mask silently loads as a normal unit.
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

      # The SDDM greeter stays password-only. pam_kwallet can only unlock the
      # wallet with the login password, so a fingerprint login leaves it locked
      # and kwallet prompts for the password anyway — two auth steps instead of
      # one. Must be an explicit false: fprintAuth defaults to
      # services.fprintd.enable, so dropping the line would leave it on.
      # The lockscreen is unaffected; it authenticates fingerprints through the
      # separate kde-fingerprint stack that the plasma6 module enables itself.
      security.pam.services.sddm.fprintAuth = false;

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
