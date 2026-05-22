{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.gtk =
    { ... }:
    {
      gtk = {
        enable = true;
        font = {
          name = fonts.sans;
          size = 11;
        };
      };
    };
}
