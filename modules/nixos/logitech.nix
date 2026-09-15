{ ... }:
{
  flake.modules.nixos.logitech = {
    hardware.logitech.wireless.enable = true;
    # Solaar, the GUI/CLI for pairing and configuring the receivers.
    # Was hardware.logitech.wireless.enableGraphical, renamed upstream.
    programs.solaar.enable = true;
  };
}
