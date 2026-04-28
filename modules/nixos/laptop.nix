{ ... }:
{
  flake.modules.nixos.laptop = {
    services.pipewire.wireplumber.extraConfig."51-hide-hdmi-audio" = {
      "monitor.alsa.rules" = [{
        matches = [{ "node.name" = "~alsa_output\\..*HDMI.*"; }];
        actions.update-props."node.disabled" = true;
      }];
    };
  };
}
