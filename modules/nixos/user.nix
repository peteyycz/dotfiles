{ config, ... }:
{
  flake.modules.nixos.user =
    { pkgs, ... }:
    {
      users.users.${config.username} = {
        isNormalUser = true;
        extraGroups = [
          "wheel"
          "docker"
          "networkmanager"
        ];
        shell = pkgs.fish;
      };
    };
}
