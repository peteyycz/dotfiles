{ lib }:

rec {
  palette = {
    bg = "#282828";
    bgHard = "#1d2021";
    bg1 = "#3c3836";
    bg2 = "#504945";
    bg3 = "#665c54";
    gray = "#928374";
    fg3 = "#bdae93";
    fg4 = "#a89984";
    fg = "#ebdbb2";
    red = "#fb4934";
    redDark = "#cc241d";
    green = "#b8bb26";
    greenDark = "#98971a";
    yellow = "#fabd2f";
    yellowDark = "#d79921";
    orange = "#fe8019";
    blue = "#83a598";
    blueDark = "#458588";
    purple = "#d3869b";
    purpleDark = "#b16286";
    aqua = "#8ec07c";
    aquaDark = "#689d6a";
  };

  c = color: lib.removePrefix "#" color;

  rgba = color: alpha:
    let
      hex = lib.removePrefix "#" color;
      hexDigit = {
        "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4;
        "5" = 5; "6" = 6; "7" = 7; "8" = 8; "9" = 9;
        "a" = 10; "b" = 11; "c" = 12; "d" = 13; "e" = 14; "f" = 15;
        "A" = 10; "B" = 11; "C" = 12; "D" = 13; "E" = 14; "F" = 15;
      };
      byte = offset:
        hexDigit.${builtins.substring offset 1 hex} * 16
        + hexDigit.${builtins.substring (offset + 1) 1 hex};
    in
      "rgba(${toString (byte 0)}, ${toString (byte 2)}, ${toString (byte 4)}, ${toString alpha})";
}
