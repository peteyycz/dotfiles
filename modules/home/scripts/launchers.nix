{ ... }:
{
  flake.modules.homeManager.launcher-scripts =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.peteyycz) scriptsDir;
    in
    {
      home.packages = [
        # Pick a *.sh from scriptsDir with rofi and run it. Kept as a binary
        # rather than an inline pipeline because Plasma global shortcuts can't
        # run a shell pipeline reliably.
        (pkgs.writeShellScriptBin "scripts-rofi" ''
          SCRIPTS="${scriptsDir}"
          SELECTED=$(find "$SCRIPTS" -maxdepth 1 -name '*.sh' -printf '%f\n' 2>/dev/null \
            | sed 's/\.sh$//' | sort | rofi -dmenu -i -p "Scripts" -theme-str 'window {width: 30%;}')
          [ -z "$SELECTED" ] && exit 0
          exec sh "$SCRIPTS/$SELECTED.sh"
        '')
      ];
    };
}
