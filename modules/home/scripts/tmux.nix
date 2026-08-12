{ ... }:
{
  flake.modules.homeManager.tmux-scripts =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.peteyycz) terminal codeRoot;
    in
    {
      home.packages = with pkgs; [
        # Focus a terminal that is already a tmux client and switch it to the
        # named session. Exits 0 if an existing terminal was reused, 1 otherwise.
        (writeShellScriptBin "tmux-focus" ''
          SESSION="$1"
          [ -z "$SESSION" ] && exit 1
          kd=${pkgs.kdotool}/bin/kdotool

          # Emit "WINID PID" for terminal windows, active one first.
          list_terms() {
            ids=$("$kd" search --class "${terminal}" 2>/dev/null)
            [ -z "$ids" ] && return 0
            active=$("$kd" getactivewindow 2>/dev/null)
            { [ -n "$active" ] && printf '%s\n' "$active"; printf '%s\n' "$ids"; } \
              | awk 'NF && !seen[$0]++' \
              | while read -r id; do
                  printf '%s\n' "$ids" | grep -qxF "$id" || continue
                  pid=$("$kd" getwindowpid "$id" 2>/dev/null)
                  [ -n "$pid" ] && printf '%s %s\n' "$id" "$pid"
                done
          }

          while read -r WINID PID; do
            [ -z "$WINID" ] && continue
            CHILD_PID=$(${pkgs.procps}/bin/pgrep -P "$PID" | head -1)
            [ -z "$CHILD_PID" ] && continue
            CAND_TTY="/dev/$(ps -o tty= -p "$CHILD_PID" | tr -d ' ')"
            if tmux list-clients -F '#{client_tty}' | grep -qx "$CAND_TTY"; then
              "$kd" windowactivate "$WINID" >/dev/null
              tmux switch-client -c "$CAND_TTY" -t "$SESSION"
              exit 0
            fi
          done < <(list_terms)

          exit 1
        '')
        (writeShellScriptBin "tmux-rofi" ''
          # Build the session list with git branch info; dirty worktrees are
          # marked by colouring the branch (rofi renders pango markup rows).
          ENTRIES=$(tmux list-sessions -F '#{session_name} #{pane_current_path}' 2>/dev/null | while read -r name path; do
            if [ -d "$path/.git" ]; then
              branch=$(${pkgs.git}/bin/git -C "$path" branch --show-current 2>/dev/null)
              dirty=$(${pkgs.git}/bin/git -C "$path" status --porcelain 2>/dev/null)
              if [ -n "$dirty" ]; then
                echo "$name <span color='#fb4934'>(#$branch)</span>"
              else
                echo "$name (#$branch)"
              fi
            else
              echo "$name"
            fi
          done)

          [ -z "$ENTRIES" ] && exit 0
          SELECTED=$(echo "$ENTRIES" | rofi -dmenu -markup-rows -p "tmux" -theme-str 'window {width: 30%;}')
          [ -z "$SELECTED" ] && exit 0
          SESSION=$(echo "$SELECTED" | awk '{print $1}')
          [ -z "$SESSION" ] && exit 0

          if ! tmux has-session -t "$SESSION" 2>/dev/null; then
            tmux new-session -d -s "$SESSION"
          fi

          # Focus an existing terminal running tmux, or open a new one.
          tmux-focus "$SESSION" && exit 0
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

          # Focus an existing terminal running tmux, or open a new one.
          tmux-focus "$SESSION" && exit 0
          exec ${terminal} tmux attach -t "$SESSION"
        '')
        (writeShellScriptBin "tmuxn" ''tmux new-session -s "$(basename "$PWD")"'')
        (writeShellScriptBin "tmuxw-close" ''
          # Determine the tmux session attached to the focused terminal.
          # Fallback: most recently attached session.
          TTY=""
          SESSION=""
          PID=""
          kd=${pkgs.kdotool}/bin/kdotool
          ACTIVE=$("$kd" getactivewindow 2>/dev/null)
          if [ -n "$ACTIVE" ] \
            && "$kd" search --class "${terminal}" 2>/dev/null | grep -qxF "$ACTIVE"; then
            PID=$("$kd" getwindowpid "$ACTIVE" 2>/dev/null)
          fi
          if [ -n "$PID" ]; then
            CHILD_PID=$(${pkgs.procps}/bin/pgrep -P "$PID" | head -1)
            if [ -n "$CHILD_PID" ]; then
              TTY="/dev/$(ps -o tty= -p "$CHILD_PID" | tr -d ' ')"
              SESSION=$(tmux list-clients -F '#{client_tty} #{session_name}' 2>/dev/null \
                | awk -v t="$TTY" '$1==t{print $2; exit}')
            fi
          fi

          if [ -z "$SESSION" ]; then
            SESSION=$(tmux list-sessions -F '#{session_last_attached} #{session_name}' 2>/dev/null \
              | sort -nr | head -1 | awk '{print $2}')
          fi

          [ -z "$SESSION" ] && exit 0

          NEXT=$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
            | grep -vx "$SESSION" | head -1)

          if [ -n "$NEXT" ] && [ -n "$TTY" ] \
            && tmux list-clients -F '#{client_tty}' 2>/dev/null | grep -qx "$TTY"; then
            tmux switch-client -c "$TTY" -t "$NEXT"
          fi

          tmux kill-session -t "$SESSION"
        '')
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
