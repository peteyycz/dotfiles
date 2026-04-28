{ ... }:
{
  flake.modules.nixos.keyring = {
    services.gnome.gnome-keyring.enable = true;
  };
}
