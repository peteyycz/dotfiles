{ ... }:
{
  flake.modules.homeManager.base = { pkgs, ... }: {
    home.stateVersion = "25.05";

    home.file.".local/share/backgrounds/default.jpg".source =
      pkgs.fetchurl (import ../../wallpaper.nix);

    home.sessionVariables.EDITOR = "vim";
    home.sessionPath = [ "$HOME/.local/bin" ];

    home.file.".npmrc".text = ''
      prefix=~/.local
    '';
  };
}
