{ inputs, ... }:
{
  flake.modules.homeManager.caelestia =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cli =
        inputs.caelestia-shell.inputs.caelestia-cli.packages.${pkgs.stdenv.hostPlatform.system}.default;
      wallpaper = "${config.home.homeDirectory}/${config.peteyycz.wallpaperPath}";
      scheme = {
        name = "everforest";
        flavour = "hard";
        mode = "dark";
      };
    in
    {
      imports = [ inputs.caelestia-shell.homeManagerModules.default ];

      programs.caelestia = {
        enable = true;
        cli.enable = true;
        settings.bar.status = {
          showAudio = true;
          showMicrophone = true;
          showKbLayout = true;
        };
        settings.paths.sessionGif = "";
        settings.services = {
          useFahrenheit = false;
          useTwelveHourClock = false;
        };
        settings.bar.tray = {
          background = true;
          recolour = true;
        };
        settings.bar.workspaces = {
          shown = 10;
          label = "";
          occupiedLabel = "";
          activeLabel = "";
          # Workspace window icons are Material Symbol glyphs, matched by window
          # class. Apps whose .desktop categories don't map (notably Chrome PWAs,
          # whose class is an opaque `chrome-<id>-Default`) fall back to the
          # `terminal` glyph, so they all look identical. Override them by class.
          windowIcons = [
            {
              regex = "chrome-kippjfofjhjlffjecoapiogbkgbpmgej"; # Messenger PWA
              icon = "chat";
            }
            {
              regex = "chrome-ompifgpmddkgmclendfeacglnodjjndh"; # Teams PWA
              icon = "groups";
            }
            {
              regex = "^Slack$";
              icon = "forum";
            }
            {
              regex = "^spotify$";
              icon = "music_note";
            }
            {
              regex = "^google-chrome$";
              icon = "web";
            }
            {
              regex = "^foot$";
              icon = "terminal";
            }
            {
              regex = "steam(_app_(default|[0-9]+))?"; # upstream default
              icon = "sports_esports";
            }
          ];
        };
        settings.general.idle.timeouts = [
          {
            timeout = 300;
            idleAction = "lock";
          }
          {
            timeout = 330;
            idleAction = "dpms off";
            returnAction = "dpms on";
          }
        ];
        settings.bar.entries = [
          {
            id = "logo";
            enabled = true;
          }
          {
            id = "workspaces";
            enabled = true;
          }
          {
            id = "spacer";
            enabled = true;
          }
          {
            id = "tray";
            enabled = true;
          }
          {
            id = "statusIcons";
            enabled = true;
          }
          {
            id = "power";
            enabled = true;
          }
        ];
      };

      home.activation.caelestiaSetWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${cli}/bin/caelestia wallpaper -f ${wallpaper} || true
      '';

      home.activation.caelestiaSetScheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${cli}/bin/caelestia scheme set \
          --name ${scheme.name} \
          --flavour ${scheme.flavour} \
          --mode ${scheme.mode} \
          || true
      '';
    };
}
