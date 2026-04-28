{ ... }:
{
  flake.modules.homeManager.tmux-scripts = { config, theme, pkgs, ... }:
    let
      inherit (config.peteyycz) terminal codeRoot;
    in {
    home.packages = with pkgs; [
      (writeShellScriptBin "tmux-rofi" ''
        # Build list of sessions with git branch info
        ENTRIES=$(tmux list-sessions -F '#{session_name} #{pane_current_path}' 2>/dev/null | while read -r name path; do
          if [ -d "$path/.git" ]; then
            branch=$(${pkgs.git}/bin/git -C "$path" branch --show-current 2>/dev/null)
            dirty=$(${pkgs.git}/bin/git -C "$path" status --porcelain 2>/dev/null)
            if [ -n "$dirty" ]; then
              echo "$name <span color='${theme.palette.red}'>(#$branch)</span>"
            else
              echo "$name (#$branch)"
            fi
          else
            echo "$name"
          fi
        done)

        SELECTED=$(echo "$ENTRIES" | rofi -dmenu -markup-rows -p "tmux" -theme-str 'window {width: 30%;}')
        [ -z "$SELECTED" ] && exit 0
        SESSION=$(echo "$SELECTED" | awk '{print $1}')
        [ -z "$SESSION" ] && exit 0

        if ! tmux has-session -t "$SESSION" 2>/dev/null; then
          tmux new-session -d -s "$SESSION"
        fi

        # Find a terminal window running tmux, preferring the most-recently-focused
        MATCH_ADDR=""
        MATCH_TTY=""
        while read -r ADDR PID; do
          [ -z "$ADDR" ] && continue
          CHILD_PID=$(${pkgs.procps}/bin/pgrep -P "$PID" | head -1)
          [ -z "$CHILD_PID" ] && continue
          CAND_TTY="/dev/$(ps -o tty= -p "$CHILD_PID" | tr -d ' ')"
          if tmux list-clients -F '#{client_tty}' | grep -qx "$CAND_TTY"; then
            MATCH_ADDR="$ADDR"
            MATCH_TTY="$CAND_TTY"
            break
          fi
        done < <(hyprctl clients -j | jq -r 'sort_by(.focusHistoryID) | .[] | select(.class=="${terminal}") | "\(.address) \(.pid)"')

        if [ -n "$MATCH_TTY" ]; then
          hyprctl dispatch focuswindow "address:$MATCH_ADDR"
          tmux switch-client -c "$MATCH_TTY" -t "$SESSION"
          exit 0
        fi

        # No terminal running tmux — open new one
        exec ${terminal} tmux attach -t "$SESSION"
      '')
      (writeShellScriptBin "tmuxw-rofi" ''
        SRC="${codeRoot}"
        ENTRIES=$(find "$SRC" -mindepth 2 -type d -name .git -prune -printf '%h\n' 2>/dev/null | sed "s|^$SRC/||" | sort)

        SELECTED=$(echo "$ENTRIES" | rofi -dmenu -p "project" -theme-str 'window {width: 40%;}')
        [ -z "$SELECTED" ] && exit 0

        PROJECT_PATH="$SRC/$SELECTED"
        [ ! -d "$PROJECT_PATH/.git" ] && exit 0

        SESSION="$(basename "$PROJECT_PATH")"
        (cd "$PROJECT_PATH" && tmuxw --detach)

        # Find a terminal window running tmux, preferring the most-recently-focused
        MATCH_ADDR=""
        MATCH_TTY=""
        while read -r ADDR PID; do
          [ -z "$ADDR" ] && continue
          CHILD_PID=$(${pkgs.procps}/bin/pgrep -P "$PID" | head -1)
          [ -z "$CHILD_PID" ] && continue
          CAND_TTY="/dev/$(ps -o tty= -p "$CHILD_PID" | tr -d ' ')"
          if tmux list-clients -F '#{client_tty}' | grep -qx "$CAND_TTY"; then
            MATCH_ADDR="$ADDR"
            MATCH_TTY="$CAND_TTY"
            break
          fi
        done < <(hyprctl clients -j | jq -r 'sort_by(.focusHistoryID) | .[] | select(.class=="${terminal}") | "\(.address) \(.pid)"')

        if [ -n "$MATCH_TTY" ]; then
          hyprctl dispatch focuswindow "address:$MATCH_ADDR"
          tmux switch-client -c "$MATCH_TTY" -t "$SESSION"
          exit 0
        fi

        # No terminal running tmux — open new one
        exec ${terminal} tmux attach -t "$SESSION"
      '')
      (writeShellScriptBin "tmuxn" ''tmux new-session -s "$(basename "$PWD")"'')
      (writeShellScriptBin "tmuxw" ''
        DETACH=false
        for arg in "$@"; do
          case "$arg" in
            --detach) DETACH=true ;;
          esac
        done

        SESSION="$(basename "$PWD")"
        if tmux has-session -t "$SESSION" 2>/dev/null; then
          exit 0
        fi
        tmux new-session -d -s "$SESSION" -c "$PWD"

        # Split horizontally: new pane on right for claude
        tmux split-window -h -l 150 -t "$SESSION:1" -c "$PWD"

        # Split the left pane vertically: top (run-server) and bottom (start-accessories)
        tmux split-window -v -t "$SESSION:1.1" -c "$PWD"
        tmux send-keys -t "$SESSION:1.1" 'run-server' Enter
        tmux send-keys -t "$SESSION:1.2" 'start-accessories' Enter

        # Start claude in the right pane (now pane 3 after the split)
        tmux send-keys -t "$SESSION:1.3" 'claude -c' Enter

        # Window 2: nvim
        tmux new-window -t "$SESSION" -c "$PWD"
        tmux send-keys -t "$SESSION:2" 'nvim .' Enter

        # Select window 1, pane 3 (claude)
        tmux select-window -t "$SESSION:1"
        tmux select-pane -t "$SESSION:1.3"

        if [ "$DETACH" = false ]; then
          tmux attach -t "$SESSION"
        fi
      '')
    ];
  };
}
