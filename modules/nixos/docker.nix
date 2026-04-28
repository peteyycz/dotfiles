{ ... }:
{
  flake.modules.nixos.docker = {
    virtualisation.docker.enable = true;
  };
}
