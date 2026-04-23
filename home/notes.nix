{ config, pkgs, lib, ... }:

let
  colorsLib = import ./colors.nix { inherit lib; };
  colors = colorsLib.palette;
in
{
  home.packages = with pkgs; [
    (writeShellScriptBin "notes-capture" ''
      set -eu
      NOTES_DIR="$HOME/Code/src/github.com/peteyycz/notes"
      INBOX="$NOTES_DIR/inbox.md"

      if [ ! -d "$NOTES_DIR" ]; then
        mkdir -p "$NOTES_DIR"
        ${pkgs.git}/bin/git -C "$NOTES_DIR" init -q
      fi

      if [ ! -f "$INBOX" ]; then
        printf '# Inbox\n\n' > "$INBOX"
      fi

      TEXT=$(rofi -dmenu -p "note" -l 0 -theme-str 'window {width: 40%;} entry { placeholder: "Capture a note..."; }')
      [ -z "$TEXT" ] && exit 0

      printf -- '- [ ] %s — %s\n' "$(date '+%Y-%m-%d %H:%M')" "$TEXT" >> "$INBOX"
    '')
    (writeShellScriptBin "notes-open" ''
      NOTES_DIR="$HOME/Code/src/github.com/peteyycz/notes"
      mkdir -p "$NOTES_DIR"
      exec foot --app-id=notes-floating --working-directory="$NOTES_DIR" nvim inbox.md
    '')
    (writeShellScriptBin "notes-stats" ''
      NOTES_DIR="$HOME/Code/src/github.com/peteyycz/notes"
      INBOX="$NOTES_DIR/inbox.md"

      [ ! -f "$INBOX" ] && exit 0

      COUNT=$(grep -c '^- \[ \]' "$INBOX" 2>/dev/null || true)
      COUNT=''${COUNT:-0}
      [ "$COUNT" = "0" ] && exit 0
      printf '%s\n' "$COUNT"
    '')
  ];

  peteyycz.hyprpanelCustomModules."custom/todos" = {
    icon = "󱃔";
    label = "{}";
    hideOnEmpty = true;
    execute = "notes-stats";
    interval = 5000;
    actions.onLeftClick = "notes-open";
  };

  peteyycz.hyprpanelCustomScss = ''
    .cmodule-todos {
      background-color: ${colors.bg}F2;
      color: ${colors.fg3};
      border-color: ${colors.bg2};
    }
  '';

  peteyycz.hyprlandExtraBinds = [
    "$mod, N, exec, notes-capture"
    "$mod SHIFT, N, exec, notes-open"
  ];

  peteyycz.hyprlandExtraWindowRules = [
    "float on, match:class ^(notes-floating)$"
    "size 60% 70%, match:class ^(notes-floating)$"
    "center 1, match:class ^(notes-floating)$"
  ];
}
