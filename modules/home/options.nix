{ ... }:
{
  flake.modules.homeManager.options = { lib, ... }: {
    options.peteyycz = {
      isLaptop = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      primaryMonitors = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      hyprlandExtraBinds = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      hyprlandExtraWindowRules = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      wayleCustomModules = lib.mkOption {
        type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
        default = { };
        description = ''
          Keyed by custom module id. Value is the Wayle custom-module config
          without the `id` field (id is injected from the attribute name).
        '';
      };
      terminal = lib.mkOption {
        type = lib.types.str;
        default = "foot";
        description = "Terminal binary name. Also used as the Hyprland window class match.";
      };
      codeRoot = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/Code/src";
        description = "Project source root. Shell-context (literal $HOME).";
      };
      scriptsDir = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/Code/src/github.com/peteyycz/scripts";
      };
      notesDir = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/Code/src/github.com/peteyycz/notes";
      };
      dotfilesDir = lib.mkOption {
        type = lib.types.str;
        default = "$HOME/Code/src/github.com/peteyycz/dotfiles";
      };
      wallpaperPath = lib.mkOption {
        type = lib.types.str;
        default = ".local/share/backgrounds/default.jpg";
        description = "Wallpaper file path relative to $HOME.";
      };
    };
  };
}
