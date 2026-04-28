{ config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.dconf = { ... }: {
    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-animations = false;
        icon-theme = "Gruvbox-Plus-Dark";
        font-name = "${fonts.sans} 11";
        document-font-name = "${fonts.sans} 11";
      };
      "org/gnome/nautilus/preferences" = {
        default-folder-viewer = "list-view";
      };
      "org/gtk/settings/file-chooser" = {
        show-hidden = true;
      };
      "org/gtk/gtk4/settings/file-chooser" = {
        show-hidden = true;
      };
    };
  };
}
