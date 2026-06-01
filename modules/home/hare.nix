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
          mode = "dark";
          fonts = {
            inherit (fonts) sans mono;
          };
          # More see-through than the hare defaults (0.46/0.55) — leans on the
          # heavier Hyprland blur for the frosted-glass read.
          palette = {
            dark.bgAlpha = 0.30;
            light.bgAlpha = 0.40;
          };
        };
      };
    };
}
