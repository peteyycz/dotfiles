{ ... }:
{
  flake.modules.nixos.desktop =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      };

      # Opt Electron/Chromium apps (Spotify, Slack, Chrome, VS Code) into the
      # Ozone Wayland backend so fractional scaling stays crisp instead of
      # being bitmap-upscaled through Xwayland.
      environment.sessionVariables.NIXOS_OZONE_WL = "1";

      # Xorg is here only to host SDDM's X11 greeter; the Plasma session
      # itself still starts on Wayland.
      services.xserver.enable = true;

      services.displayManager = {
        defaultSession = "plasma";
        sddm = {
          enable = true;
          # X11 greeter, not Wayland. SDDM's Wayland greeter runs its own
          # kwin_wayland; when the user picks a Plasma session the two KWin
          # instances race for DRM master (see "Atomic modeset test failed!
          # Permission denied" in the KWin logs), fbcon takes the console,
          # and the display goes to a text-mode black screen. Launching the
          # Wayland session from an X11 greeter cleanly releases the display.
          wayland.enable = false;
        };
      };
    };
}
