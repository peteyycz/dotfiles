{ ... }:
{
  flake.modules.nixos.laptop = {
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
    services.logind = {
      lidSwitch = "suspend";
      lidSwitchExternalPower = "suspend";
    };
  };
}
