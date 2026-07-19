{ inputs, config, ... }:
let
  fonts = config.fontFamilies;
in
{
  flake.modules.homeManager.hare =
    { lib, ... }:
    {
      imports = [ inputs.hare.homeManagerModules.default ];

      programs.hare = {
        enable = true;
        theme = {
          fonts = {
            inherit (fonts) sans mono;
          };
          # More see-through than the hare default (0.46) — leans on the
          # heavier Hyprland blur for the frosted-glass read.
          palette = {
            bgAlpha = 0.30;
          };
        };
      };

      # Upstream hare hardcodes graphical-session.target; force it onto
      # hyprland-session.target so the bar doesn't launch under KDE.
      systemd.user.services.hare = {
        Unit = {
          PartOf = lib.mkForce [ "hyprland-session.target" ];
          After = lib.mkForce [ "hyprland-session.target" ];
        };
        Install.WantedBy = lib.mkForce [ "hyprland-session.target" ];
      };
    };
}
