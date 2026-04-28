{ ... }:
{
  flake.modules.homeManager.cursor = { pkgs, ... }: {
    home.pointerCursor = {
      name = "macOS";
      package = pkgs.apple-cursor;
      size = 24;
      gtk.enable = true;
    };
  };
}
