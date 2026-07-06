{ ... }:
{
  flake.modules.nixos.packages =
    { pkgs, ... }:
    let
      # The user gtk.css (~/.config/gtk-4.0/gtk.css) paints every window with
      # `alpha(bg, 0.30)` for the glass look. pavucontrol is gtkmm4 but not
      # libadwaita, so it takes that direct selector and ends up unreadable
      # over the wallpaper. GTK4 has no per-app CSS scoping, so point it at
      # an empty XDG_CONFIG_HOME to skip the user CSS entirely, and force
      # Adwaita:dark since dconf lookups (which set the dark preference)
      # also go through XDG_CONFIG_HOME.
      pavucontrolReadable = pkgs.symlinkJoin {
        name = "pavucontrol-readable";
        paths = [ pkgs.pavucontrol ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          empty=${
            pkgs.runCommand "pavucontrol-empty-gtk-config" { } ''
              mkdir -p $out/gtk-3.0 $out/gtk-4.0
            ''
          }
          wrapProgram $out/bin/pavucontrol \
            --set XDG_CONFIG_HOME "$empty" \
            --set GTK_THEME "Adwaita:dark"
        '';
      };
    in
    {
      environment.systemPackages = with pkgs; [
        pavucontrolReadable

        unzip

        stow
        git
        wl-clipboard

        google-chrome
        rustdesk
        slack
        nautilus
        nautilus-open-any-terminal
        file-roller
        sushi
        brightnessctl
        wev
        openssl
        tree-sitter
        pam_u2f
        jdk21
        maven
        python3
        psmisc
        parted
        lshw
      ];
    };
}
