{ inputs, ... }:
{
  flake.modules.homeManager.plasma =
    { ... }:
    {
      imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

      programs.plasma = {
        enable = true;

        # Darkly colors + Darkly application (widget) style (pkgs.darkly, in the
        # nixos plasma module), with the stock Breeze window decoration.
        # Gruvbox is used in the terminal/editor stack (ghostty/nvim/tmux).
        workspace = {
          colorScheme = "Darkly";
          iconTheme = "Nordzy";
          windowDecorations = {
            library = "org.kde.breeze";
            theme = "Breeze";
          };
          cursor = {
            theme = "macOS";
            size = 24;
          };
        };

        # Application (widget) style. widgetStyle name comes from Darkly's
        # kstyle themerc ([KDE] WidgetStyle=Darkly).
        configFile.kdeglobals.KDE.widgetStyle = "Darkly";

        # Caps Lock acts as Ctrl. Layouts cycle with Alt+Shift, bound under
        # "KDE Keyboard Layout Switcher" below.
        input.keyboard = {
          options = [ "ctrl:nocaps" ];
          layouts = [
            { layout = "us"; }
            {
              layout = "hu";
              variant = "qwerty";
            }
          ];
        };

        # Global shortcuts, captured from the KDE UI (rc2nix-style).
        # [ ] = intentionally unbound. Managed here so both machines match.
        shortcuts = {
          "KDE Keyboard Layout Switcher" = {
            "Switch to Last-Used Keyboard Layout" = [ ];
            "Switch to Next Keyboard Layout" = "Alt+Shift";
          };
          "kaccess" = {
            "Toggle Screen Reader On and Off" = [ ];
          };
          "kwin" = {
            "Edit Tiles" = [ ];
            "Expose" = [ ];
            "ExposeAll" = [ ];
            "ExposeClass" = [ ];
            "Grid View" = [ ];
            "Kill Window" = [ ];
            "MoveMouseToCenter" = [ ];
            "MoveMouseToFocus" = [ ];
            "Overview" = [ ];
            "Show Desktop" = [ ];
            "Switch One Desktop Down" = [ ];
            "Switch One Desktop Up" = [ ];
            "Switch One Desktop to the Left" = [ ];
            "Switch One Desktop to the Right" = [ ];
            "Switch Window Down" = [ ];
            "Switch Window Left" = [ ];
            "Switch Window Right" = [ ];
            "Switch Window Up" = [ ];
            "Switch to Desktop 1" = [ ];
            "Switch to Desktop 2" = [ ];
            "Switch to Desktop 3" = [ ];
            "Switch to Desktop 4" = [ ];
            "Window Close" = "Meta+Q";
            "Window Maximize" = [ ];
            "Window Minimize" = [ ];
            "Window One Desktop Down" = [ ];
            "Window One Desktop Up" = [ ];
            "Window One Desktop to the Left" = [ ];
            "Window One Desktop to the Right" = [ ];
            "Window Operations Menu" = [ ];
            "Window Quick Tile Bottom" = [ ];
            "Window Quick Tile Left" = [ ];
            "Window Quick Tile Right" = [ ];
            "Window Quick Tile Top" = [ ];
            "Window to Next Screen" = [ ];
            "Window to Previous Screen" = [ ];
            "disableInputCapture" = [ ];
          };
          "plasmashell" = {
            "activate task manager entry 1" = [ ];
            "activate task manager entry 2" = [ ];
            "activate task manager entry 3" = [ ];
            "activate task manager entry 4" = [ ];
            "activate task manager entry 5" = [ ];
            "activate task manager entry 6" = [ ];
            "activate task manager entry 7" = [ ];
            "activate task manager entry 8" = [ ];
            "activate task manager entry 9" = [ ];
            "cycle-panels" = [ ];
            "manage activities" = [ ];
            "show dashboard" = [ ];
            "show-on-mouse-pos" = [ ];
          };
          # Disabled default app-launch shortcuts (e.g. Meta+. emoji picker).
          "services/org.kde.dolphin.desktop"."_launch" = [ ];
          "services/org.kde.konsole.desktop"."_launch" = [ ];
          "services/org.kde.plasma.emojier.desktop"."_launch" = [ ];
          "services/systemsettings.desktop"."_launch" = [ ];
        };

        # Custom global shortcuts for the tmux/scripts launchers.
        hotkeys.commands = {
          tmuxw-close = {
            name = "close current tmux session";
            key = "Meta+Ctrl+W";
            command = "tmuxw-close";
          };
        };

        # No folder view, no icons — wallpaper is all that renders on the
        # desktop layer. Same underlying package as org.kde.plasma.folder,
        # but this plugin name flips the internal isFolder flag off. Right-
        # clicking still works.
        configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
          "Containments/1".plugin = "org.kde.desktopcontainment";
        };

        # Trim KRunner (Alt+Space) to just Applications + workspace switcher.
        # .so-based runners have no explicit "Id" in their metadata, so their
        # pluginId falls back to the filename (`krunner_placesrunner` etc.),
        # which is what `<pluginId>Enabled` must match.
        configFile.krunnerrc.Plugins = {
          baloosearchEnabled = false;
          windowsEnabled = false;
          krunner_bookmarksrunnerEnabled = false;
          krunner_placesrunnerEnabled = false;
          krunner_recentdocumentsEnabled = false;
          krunner_systemsettingsEnabled = false;
        };
      };
    };
}
