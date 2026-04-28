{ ... }:
{
  flake.modules.homeManager.starship = {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings.aws.disabled = true;
    };
  };
}
