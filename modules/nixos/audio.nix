{ ... }:
{
  flake.modules.nixos.audio = {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };
}
