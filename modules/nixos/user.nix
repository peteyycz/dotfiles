{ config, ... }:
{
  flake.modules.nixos.user =
    { pkgs, ... }:
    {
      users.users.${config.username} = {
        isNormalUser = true;
        initialHashedPassword = "$y$j9T$uK/aiGt.zHvfefnb2.0l/1$0D4ZO5Mk4kVbqTsBXYiypeIYCMZqfUAETuNsntFeus2";
        extraGroups = [
          "wheel"
          "docker"
          "networkmanager"
        ];
        shell = pkgs.fish;
      };
    };
}
