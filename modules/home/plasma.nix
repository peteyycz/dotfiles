{ inputs, ... }:
{
  flake.modules.homeManager.plasma =
    { ... }:
    {
      imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

      programs.plasma = {
        enable = true;

        workspace.cursor = {
          theme = "macOS";
          size = 24;
        };

        # Empty desktop containment: no folder view, no icons — the wallpaper
        # is all that renders on the desktop layer. Right-clicking still works.
        configFile."plasma-org.kde.plasma.desktop-appletsrc" = {
          "Containments/1".plugin = "org.kde.plasma.emptyContainment";
        };
      };
    };
}
