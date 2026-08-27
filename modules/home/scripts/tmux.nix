{ ... }:
{
  flake.modules.homeManager.tmux-scripts =
    {
      config,
      pkgs,
      ...
    }:
    let
      inherit (config.peteyycz) terminal codeRoot scriptsDir;
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
        (writeShellScriptBin "tmuxn" ''tmux new-session -s "$(basename "$PWD")"'')
        # In-tmux session switcher: fzf inside a display-popup, substring/fuzzy
        # matching. Sessions are annotated with their git branch (red = dirty
        # worktree) rendered via fzf --ansi. Bound to prefix+a in tmux.nix.
        (writeShellScriptBin "tmux-switch" ''
          ENTRIES=$(tmux list-sessions -F '#{session_name} #{pane_current_path}' 2>/dev/null | while read -r name path; do
            info=""
            if [ -d "$path/.git" ]; then
              branch=$(${pkgs.git}/bin/git -C "$path" branch --show-current 2>/dev/null)
              if [ -n "$branch" ]; then
                if [ -n "$(${pkgs.git}/bin/git -C "$path" status --porcelain 2>/dev/null)" ]; then
                  info=" $(printf '\033[31m(#%s)\033[0m' "$branch")"
                else
                  info=" $(printf '\033[90m(#%s)\033[0m' "$branch")"
                fi
              fi
            fi
            printf '%s%s\n' "$name" "$info"
          done)

          [ -z "$ENTRIES" ] && exit 0
          SELECTED=$(printf '%s\n' "$ENTRIES" \
            | ${pkgs.fzf}/bin/fzf --ansi --no-sort --reverse --prompt='session> ' --header='switch session') || exit 0
          SESSION=$(printf '%s' "$SELECTED" | awk '{print $1}')
          [ -z "$SESSION" ] && exit 0
          tmux switch-client -t "$SESSION"
        '')
        # In-tmux project picker: fzf over git repos under codeRoot, build the
        # session with tmuxw and switch to it. Bound to prefix+p in tmux.nix.
        (writeShellScriptBin "tmux-project" ''
          SRC="${codeRoot}"
          SELECTED=$(find "$SRC" -mindepth 2 -type d -name .git -prune -printf '%h\n' 2>/dev/null \
            | sed "s|^$SRC/||" | sort \
            | ${pkgs.fzf}/bin/fzf --reverse --prompt='project> ' --header='open project') || exit 0
          [ -z "$SELECTED" ] && exit 0

          PROJECT_PATH="$SRC/$SELECTED"
          [ ! -d "$PROJECT_PATH/.git" ] && exit 0
          SESSION="$(basename "$PROJECT_PATH")"
          (cd "$PROJECT_PATH" && tmuxw --detach)
          tmux switch-client -t "$SESSION"
        '')
        # In-tmux scripts picker: fzf over *.sh in scriptsDir, run the choice in
        # a new tmux window so its output stays visible. Bound to prefix+P.
        (writeShellScriptBin "tmux-scripts" ''
          SCRIPTS="${scriptsDir}"
          SELECTED=$(find "$SCRIPTS" -maxdepth 1 -name '*.sh' -printf '%f\n' 2>/dev/null \
            | sed 's/\.sh$//' | sort \
            | ${pkgs.fzf}/bin/fzf --reverse --prompt='script> ' --header='run script') || exit 0
          [ -z "$SELECTED" ] && exit 0
          tmux new-window -n "$SELECTED" "sh '$SCRIPTS/$SELECTED.sh'"
        '')
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
