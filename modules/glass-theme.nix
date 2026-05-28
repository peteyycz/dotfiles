{ inputs, lib, ... }:
{
  # Neutral "liquid glass" palette (dark + light tones), sourced from the hare
  # flake so the bar and every other themed surface (rofi, hyprlock, polkit)
  # share one set of colours. Single source of truth, like fontFamilies.
  options.glassTheme = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.anything);
    default = inputs.hare.lib.glass;
    readOnly = true;
    description = "Neutral glass palette { dark, light } shared by hare and themed surfaces.";
  };
}
