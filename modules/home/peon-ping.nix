{ inputs, ... }:
{
  flake.modules.homeManager.peon-ping =
    { pkgs, ... }:
    let
      pkg = inputs.peon-ping.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      imports = [ inputs.peon-ping.homeManagerModules.default ];
      programs.peon-ping = {
        enable = true;
        package = pkg;
        installPacks = [ "peon" ];
        settings = {
          enabled = true;
          desktop_notifications = false;
          volume = 0.5;
          default_pack = "peon";
        };
      };
      home.packages = [ pkg ];
    };
}
