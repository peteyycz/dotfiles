{ ... }:
{
  flake.modules.homeManager.base =
    { config, pkgs, ... }:
    {
      home.stateVersion = "25.05";

      home.file.${config.peteyycz.wallpaperPath}.source = pkgs.fetchurl (import ../../wallpaper.nix);

      home.sessionVariables.EDITOR = "vim";
      home.sessionPath = [ "$HOME/.local/bin" ];

      home.file.".npmrc".text = ''
        prefix=~/.local
        @oktogon-media:registry=https://npm.pkg.github.com
        //npm.pkg.github.com/:_authToken=''${GITHUB_TOKEN}
      '';
    };
}
