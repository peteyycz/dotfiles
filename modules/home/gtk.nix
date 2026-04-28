{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.gtk = { theme, pkgs, ... }: {
    gtk = {
      enable = true;
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
      gtk4.theme = null;
      font = {
        name = fonts.sans;
        size = 11;
      };
      iconTheme = {
        name = "Gruvbox-Plus-Dark";
        package = pkgs.gruvbox-plus-icons;
      };
      gtk4.extraCss = ''
        @define-color window_bg_color ${theme.palette.bgHard};
        @define-color window_fg_color ${theme.palette.fg};
        @define-color view_bg_color ${theme.palette.bg};
        @define-color view_fg_color ${theme.palette.fg};
        @define-color headerbar_bg_color ${theme.palette.bgHard};
        @define-color headerbar_fg_color ${theme.palette.fg};
        @define-color headerbar_border_color ${theme.palette.bg1};
        @define-color headerbar_backdrop_color ${theme.palette.bgHard};
        @define-color sidebar_bg_color ${theme.palette.bgHard};
        @define-color sidebar_fg_color ${theme.palette.fg3};
        @define-color sidebar_backdrop_color ${theme.palette.bgHard};
        @define-color secondary_sidebar_bg_color ${theme.palette.bg};
        @define-color secondary_sidebar_fg_color ${theme.palette.fg3};
        @define-color card_bg_color ${theme.palette.bg1};
        @define-color card_fg_color ${theme.palette.fg};
        @define-color popover_bg_color ${theme.palette.bg};
        @define-color popover_fg_color ${theme.palette.fg};
        @define-color dialog_bg_color ${theme.palette.bg};
        @define-color dialog_fg_color ${theme.palette.fg};
        @define-color accent_bg_color ${theme.palette.orange};
        @define-color accent_fg_color ${theme.palette.bgHard};
        @define-color accent_color ${theme.palette.yellow};
        @define-color destructive_bg_color ${theme.palette.redDark};
        @define-color destructive_fg_color ${theme.palette.fg};
        @define-color destructive_color ${theme.palette.red};
        @define-color success_bg_color ${theme.palette.greenDark};
        @define-color success_color ${theme.palette.green};
        @define-color warning_bg_color ${theme.palette.yellowDark};
        @define-color warning_color ${theme.palette.yellow};
        @define-color error_bg_color ${theme.palette.redDark};
        @define-color error_color ${theme.palette.red};
      '';
    };
  };
}
