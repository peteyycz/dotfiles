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
        settings.bar.workspaces = {
          label = "";
          occupiedLabel = "";
          activeLabel = "";
        };
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
            id = "activeWindow";
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
