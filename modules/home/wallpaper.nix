{ ... }:
{
  flake.modules.homeManager.wallpaper =
    { config, pkgs, ... }:
    let
      wallpaper = "${config.home.homeDirectory}/${config.peteyycz.wallpaperPath}";
      wallpaperFile = ../../wallpapers/dusk.jpg;
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

          # Pass the resolved store path, not the symlink: awww caches by the
          # path string, so a constant symlink path would keep serving the
          # first-cached image even after the wallpaper changes.
          wp="$(readlink -f "${wallpaper}" 2>/dev/null || echo "${wallpaper}")"
          awww img "$wp" || true
          wait "$daemon_pid"
        '';
      };
    in
    {
      home.packages = [ pkgs.awww ];

      systemd.user.services.wallpaper = {
        Unit = {
          Description = "Wayland wallpaper daemon (awww)";
          PartOf = [ "hyprland-session.target" ];
          After = [ "hyprland-session.target" ];
          # Restart the service on switch whenever the wallpaper image changes,
          # so a new wallpaper actually gets applied.
          X-Restart-Triggers = [ "${wallpaperFile}" ];
        };
        Install.WantedBy = [ "hyprland-session.target" ];
        Service = {
          ExecStart = "${wallpaperInit}/bin/wallpaper-init";
          Restart = "on-failure";
          RestartSec = 2;
        };
      };
    };
}
