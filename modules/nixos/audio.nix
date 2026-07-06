{ ... }:
{
  flake.modules.nixos.audio = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;

      # The Cirrus CS8409/CS42L42 codec on this Dell exposes a Headphone
      # Playback Volume but not a Headphone Playback Switch, so ALSA's UCM
      # profile (HDA/HiFi-analog.conf) skips defining the analog Headphones
      # and Headset-Mic devices. Wireplumber then only surfaces Speaker +
      # Digital Mic, and the 3.5mm headset jack is invisible to apps like
      # Slack even though jack detection fires correctly. Turning UCM off
      # for this card makes wireplumber fall back to legacy ACP enumeration
      # which handles the missing-switch case.
      wireplumber.extraConfig."51-sof-hda-disable-ucm" = {
        "monitor.alsa.rules" = [
          {
            matches = [ { "device.name" = "~alsa_card\\..*hda_dsp.*"; } ];
            actions.update-props = {
              "api.alsa.use-ucm" = false;
            };
          }
        ];
      };
    };
  };
}
