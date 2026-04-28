{ inputs, ... }:
{
  flake.modules.homeManager.caldy = { theme, ... }: {
    imports = [ inputs.caldy.homeManagerModules.default ];
    programs.caldy = {
      enable = true;
      settings = {
        week = {
          show_weekend = false;
          start_day = "monday";
        };
        theme = {
          bg         = theme.palette.bg;
          surface    = theme.palette.bg1;
          surface_hi = theme.palette.bg2;
          fg         = theme.palette.fg;
          fg_muted   = theme.palette.fg4;
          accent     = theme.palette.yellow;
          danger     = theme.palette.red;
        };
      };
    };
  };
}
