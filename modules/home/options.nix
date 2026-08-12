{ ... }:
{
  flake.modules.homeManager.options =
    { lib, ... }:
    {
      options.peteyycz = {
        autostart = lib.mkOption {
          type = lib.types.attrsOf lib.types.str;
          default = { };
          description = "Login apps, as name -> command. Rendered into ~/.config/autostart.";
        };
        terminal = lib.mkOption {
          type = lib.types.str;
          default = "foot";
          description = "Terminal binary name. Also used as the window class match.";
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
