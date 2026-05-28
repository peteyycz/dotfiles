{ ... }:
{
  flake.modules.homeManager.wallpaper =
    { config, pkgs, ... }:
    let
      wallpaper = "${config.home.homeDirectory}/${config.peteyycz.wallpaperPath}";
      # awww is the renamed swww (Wayland wallpaper daemon).
      wallpaperInit = pkgs.writeShellApplication {
        name = "wallpaper-init";
        runtimeInputs = [
          pkgs.awww
          pkgs.coreutils
        ];
        text = ''
          awww-daemon &
          daemon_pid=$!

          for _ in $(seq 1 50); do
            awww query >/dev/null 2>&1 && break
            sleep 0.1
          done

          awww img "${wallpaper}" || true
          wait "$daemon_pid"
        '';
      };
    in
    {
      home.packages = [ pkgs.awww ];

      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Wayland wallpaper daemon (awww)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Service = {
          ExecStart = "${wallpaperInit}/bin/wallpaper-init";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
