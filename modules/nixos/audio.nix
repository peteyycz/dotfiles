{ ... }:
{
  flake.modules.nixos.audio = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;

      # NOTE: We used to disable ALSA UCM for this card
      # (api.alsa.use-ucm = false) to make the 3.5mm headset jack visible on
      # the Cirrus CS8409/CS42L42 codec, which was missing a Headphone
      # Playback Switch and tripped up older alsa-ucm-conf. The cost was that
      # ACP fallback never routed the internal SOF digital mics, so the
      # built-in microphone captured pure silence. Newer alsa-ucm-conf
      # (>=1.2.15) fixes the CS42L42 headset handling, so UCM is left enabled
      # to keep both the internal mic and the headset jack working. If the
      # headset jack regresses, prefer a per-card UCM override over disabling
      # UCM wholesale.
    };
  };
}
