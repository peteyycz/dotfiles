{ inputs, config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.hare =
    { config, ... }:
    {
      imports = [ inputs.hare.homeManagerModules.default ];

      programs.hare = {
        enable = true;
        wallpaper = "${config.home.homeDirectory}/${config.peteyycz.wallpaperPath}";
        theme = {
          mode = "adaptive";
          fonts = {
            inherit (fonts) sans mono;
          };
        };
        bar.style = "floating";
      };
    };
}
