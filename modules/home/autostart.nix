{ ... }:
{
  # Login apps. KDE reads ~/.config/autostart/*.desktop, which is also the
  # cross-desktop convention, so the entries stay compositor-agnostic.
  flake.modules.homeManager.autostart =
    { config, lib, ... }:
    let
      inherit (config.peteyycz) scriptsDir autostart;
    in
    {
      peteyycz.autostart = {
        onepassword = "1password --silent";
        chrome = "google-chrome-stable";
        slack = "slack --startup";
        dev-start = "sh -c 'test -x ${scriptsDir}/@peteyycz:dev-start.sh && ${scriptsDir}/@peteyycz:dev-start.sh'";
      };

      xdg.configFile = lib.mapAttrs' (
        name: command:
        lib.nameValuePair "autostart/${name}.desktop" {
          text = ''
            [Desktop Entry]
            Type=Application
            Name=${name}
            Exec=${command}
            X-GNOME-Autostart-enabled=true
          '';
        }
      ) autostart;
    };
}
