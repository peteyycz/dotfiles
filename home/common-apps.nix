{ config, pkgs, lib, ... }:

let
  colorsLib = import ./colors.nix { inherit lib; };
  colors = colorsLib.palette;
  inherit (colorsLib) c rgba;

  open-runde = pkgs.stdenvNoCC.mkDerivation {
    pname = "open-runde";
    version = "1.0.1";
    src = pkgs.fetchzip {
      url = "https://github.com/lauridskern/open-runde/releases/download/v1.0.1/OpenRunde-1.0.1.zip";
      sha256 = "1nv2124hpkmvn5byk9xnm3vq7nh0ivlld0nndmm5dvw142mf222x";
      stripRoot = false;
    };
    installPhase = ''
      install -Dm644 -t $out/share/fonts/opentype "$src"/OpenRunde-1.0.1/desktop/*.otf
    '';
    meta = {
      description = "A soft, rounded variant of Inter";
      homepage = "https://github.com/lauridskern/open-runde";
      license = lib.licenses.ofl;
    };
  };
in
{
  home.packages = with pkgs; [
    libnotify
    slurp
    wf-recorder
    jq
    inter
    open-runde
    grimblast
    (lib.lowPrio papirus-icon-theme)
  ];

  programs.rofi = {
    enable = true;
    font = "Open Runde 13";
    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
      icon-theme = "Papirus-Dark";
      display-drun = "";
      display-run = "";
      display-window = "";
      display-combi = "";
      drun-display-format = "{name}";
      kb-remove-char-forward = "Delete";
      kb-remove-to-sol = "";
      kb-page-prev = "Control+u";
      kb-page-next = "Control+d";
      kb-delete-entry = "";
    };
    theme = let inherit (config.lib.formats.rasi) mkLiteral; in {
      "*" = {
        bg = mkLiteral colors.bg;
        bg1 = mkLiteral colors.bg1;
        bg2 = mkLiteral colors.bg2;
        gray = mkLiteral colors.gray;
        fg3 = mkLiteral colors.fg3;
        fg = mkLiteral colors.fg;
        red = mkLiteral colors.red;
        yellow = mkLiteral colors.yellow;
        blue = mkLiteral colors.blue;
        purple = mkLiteral colors.purple;
        aqua = mkLiteral colors.aqua;
        background-color = mkLiteral "transparent";
        text-color = mkLiteral "@fg";
        highlight = mkLiteral "bold ${colors.purple}";
      };
      window = {
        width = mkLiteral "560px";
        background-color = mkLiteral (rgba colors.bg 0.75);
        border = mkLiteral "0";
        border-radius = mkLiteral "14px";
      };
      mainbox = {
        padding = mkLiteral "12px";
      };
      inputbar = {
        padding = mkLiteral "10px 16px";
        margin = mkLiteral "0 0 12px 0";
        background-color = mkLiteral "@bg1";
        border-radius = mkLiteral "9999px";
        children = map mkLiteral [ "prompt" "textbox-prompt-colon" "entry" ];
      };
      prompt = {
        text-color = mkLiteral "@purple";
      };
      "textbox-prompt-colon" = {
        expand = false;
        str = " ";
      };
      entry = {
        placeholder = "Search...";
        placeholder-color = mkLiteral "@gray";
        text-color = mkLiteral "@fg";
      };
      listview = {
        lines = 8;
        columns = 1;
        fixed-height = true;
        spacing = mkLiteral "4px";
      };
      element = {
        padding = mkLiteral "8px 14px";
        border-radius = mkLiteral "10px";
        spacing = mkLiteral "10px";
      };
      "element selected" = {
        background-color = mkLiteral "@bg2";
        text-color = mkLiteral "@purple";
        border-radius = mkLiteral "10px";
      };
      element-icon = {
        size = mkLiteral "24px";
        margin = mkLiteral "0 10px 0 0";
      };
      element-text = {
        vertical-align = mkLiteral "0.5";
      };
    };
  };

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        ignore_empty_input = true;
        hide_cursor = true;
        grace = 0;
      };

      background = [{
        monitor = "";
        path = "${config.home.homeDirectory}/.local/share/backgrounds/default.jpg";
        blur_passes = 3;
        blur_size = 8;
      }];

      input-field = [{
        monitor = "";
        size = "300, 60";
        position = "0, -80";
        halign = "center";
        valign = "center";
        outline_thickness = 4;
        dots_size = 0.25;
        dots_spacing = 0.4;
        dots_center = true;
        rounding = 30;
        outer_color = "rgb(${c colors.bg1})";
        inner_color = "rgb(${c colors.bg})";
        font_color = "rgb(${c colors.fg})";
        check_color = "rgb(${c colors.blueDark})";
        fail_color = "rgb(${c colors.red})";
        capslock_color = "rgb(${c colors.yellow})";
        placeholder_text = "<i>Password...</i>";
        fail_text = "<i>$FAIL ($ATTEMPTS)</i>";
        fade_on_empty = false;
      }];

      label = [{
        monitor = "";
        text = "cmd[update:1000] date +'%H:%M'";
        color = "rgb(${c colors.fg})";
        font_size = 80;
        font_family = "Open Runde";
        position = "0, 160";
        halign = "center";
        valign = "center";
      }];
    };
  };

  services.playerctld.enable = true;

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 330;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
      ];
    };
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "VictorMono Nerd Font Mono:style=Medium:size=14";
        pad = "7x7";
        selection-target = "clipboard";
      };
      url = {
        launch = "xdg-open \${url}";
      };
      key-bindings = {
        show-urls-launch = "Control+Shift+o";
      };
      colors-dark = {
        alpha = "0.95";
        background = c colors.bg;
        foreground = c colors.fg;
        regular0 = c colors.bg;
        regular1 = c colors.redDark;
        regular2 = c colors.greenDark;
        regular3 = c colors.yellowDark;
        regular4 = c colors.blueDark;
        regular5 = c colors.purpleDark;
        regular6 = c colors.aquaDark;
        regular7 = c colors.fg4;
        bright0 = c colors.gray;
        bright1 = c colors.red;
        bright2 = c colors.green;
        bright3 = c colors.yellow;
        bright4 = c colors.blue;
        bright5 = c colors.purple;
        bright6 = c colors.aqua;
        bright7 = c colors.fg;
      };
    };
  };
}
