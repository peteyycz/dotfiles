{ inputs, config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.hare =
    { ... }:
    {
      imports = [ inputs.hare.homeManagerModules.default ];

      programs.hare = {
        enable = true;
        theme = {
          fonts = {
            inherit (fonts) sans mono;
          };
          # More see-through than the hare default (0.46) — leans on the
          # heavier Hyprland blur for the frosted-glass read.
          palette = {
            bgAlpha = 0.30;
          };
        };
      };
    };
}
