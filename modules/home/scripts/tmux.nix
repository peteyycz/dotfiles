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

      # KRunner D-Bus runner: surfaces tmux sessions directly in the launcher
      # (Meta / Alt+Space) and hands the chosen one to `tmux-focus`. Registered
      # via the xdg.dataFile entries at the bottom of this module.
      tmuxKrunner = pkgs.writeScriptBin "tmux-krunner" ''
        #!${
          pkgs.python3.withPackages (ps: [
            ps.dbus-python
            ps.pygobject3
          ])
        }/bin/python3
        import os
        import subprocess

        import dbus
        import dbus.service
        from dbus.mainloop.glib import DBusGMainLoop
        from gi.repository import GLib

        # Make home-manager / system binaries resolvable under D-Bus activation,
        # whose environment is more minimal than an interactive shell's.
        os.environ["PATH"] = (
            os.path.expanduser("~/.nix-profile/bin")
            + ":/run/current-system/sw/bin:"
            + os.environ.get("PATH", "")
        )

        SERVICE = "org.peteyycz.tmuxrunner"
        OBJPATH = "/tmuxrunner"
        IFACE = "org.kde.krunner1"
        TERMINAL = "${terminal}"


        def sessions():
            try:
                out = subprocess.run(
                    ["tmux", "list-sessions", "-F",
                     "#{session_name}\t#{pane_current_path}"],
                    capture_output=True, text=True,
                ).stdout
            except FileNotFoundError:
                return []
            items = []
            for line in out.splitlines():
                if not line.strip():
                    continue
                parts = line.split("\t")
                items.append((parts[0], parts[1] if len(parts) > 1 else ""))
            return items


        def subtext(path):
            if not path or not os.path.isdir(os.path.join(path, ".git")):
                return "tmux session"

            def git(*a):
                return subprocess.run(
                    ["git", "-C", path, *a],
                    capture_output=True, text=True,
                ).stdout.strip()

            branch = git("branch", "--show-current")
            if not branch:
                return "tmux session"
            dirty = " *" if git("status", "--porcelain") else ""
            return "#" + branch + dirty


        class Runner(dbus.service.Object):
            def __init__(self):
                bus = dbus.service.BusName(SERVICE, dbus.SessionBus())
                dbus.service.Object.__init__(self, bus, OBJPATH)

            @dbus.service.method(IFACE, in_signature="s",
                                 out_signature="a(sssida{sv})")
            def Match(self, query):
                q = query.strip().lower()
                trigger = q.startswith("tmux")
                if trigger:
                    q = q[4:].strip()
                out = []
                for name, path in sessions():
                    nl = name.lower()
                    if trigger:
                        if q and q not in nl:
                            continue
                        exact = q == nl
                    else:
                        if len(q) < 2 or q not in nl:
                            continue
                        exact = nl.startswith(q)
                    props = {"subtext": subtext(path)}
                    out.append((name, name, "utilities-terminal",
                                100 if exact else 30,
                                1.0 if exact else 0.7, props))
                return out

            @dbus.service.method(IFACE, in_signature="ss", out_signature="")
            def Run(self, match_id, action_id):
                if subprocess.run(
                        ["tmux", "has-session", "-t", match_id]).returncode != 0:
                    subprocess.run(["tmux", "new-session", "-d", "-s", match_id])
                if subprocess.run(["tmux-focus", match_id]).returncode != 0:
                    subprocess.Popen([TERMINAL, "tmux", "attach", "-t", match_id])

            @dbus.service.method(IFACE, out_signature="a(sss)")
            def Actions(self):
                return []


        DBusGMainLoop(set_as_default=True)
        Runner()
        GLib.MainLoop().run()
      '';
    in
    {
      home.packages = with pkgs; [
        tmuxKrunner
        # Focus a terminal that is already a tmux client and switch it to the
        # named session. Compositor-agnostic: Hyprland via hyprctl, KDE Plasma
        # via kdotool. Exits 0 if an existing terminal was reused, 1 otherwise.
        (writeShellScriptBin "tmux-focus" ''
          SESSION="$1"
          [ -z "$SESSION" ] && exit 1

          # Emit "WINID PID" for terminal windows, most-recently-focused first.
          list_terms() {
            if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
              hyprctl clients -j | jq -r \
                'sort_by(.focusHistoryID) | .[] | select(.class=="${terminal}") | "\(.address) \(.pid)"'
            else
              kd=${pkgs.kdotool}/bin/kdotool
              ids=$("$kd" search --class "${terminal}" 2>/dev/null)
              [ -z "$ids" ] && return 0
              active=$("$kd" getactivewindow 2>/dev/null)
              # Active window first (if it is a terminal), then the rest.
              { [ -n "$active" ] && printf '%s\n' "$active"; printf '%s\n' "$ids"; } \
                | awk 'NF && !seen[$0]++' \
                | while read -r id; do
                    printf '%s\n' "$ids" | grep -qxF "$id" || continue
                    pid=$("$kd" getwindowpid "$id" 2>/dev/null)
                    [ -n "$pid" ] && printf '%s %s\n' "$id" "$pid"
                  done
            fi
          }

          focus_win() {
            if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
              hyprctl dispatch focuswindow "address:$1" >/dev/null
            else
              ${pkgs.kdotool}/bin/kdotool windowactivate "$1" >/dev/null
            fi
          }

          while read -r WINID PID; do
            [ -z "$WINID" ] && continue
            CHILD_PID=$(${pkgs.procps}/bin/pgrep -P "$PID" | head -1)
            [ -z "$CHILD_PID" ] && continue
            CAND_TTY="/dev/$(ps -o tty= -p "$CHILD_PID" | tr -d ' ')"
            if tmux list-clients -F '#{client_tty}' | grep -qx "$CAND_TTY"; then
              focus_win "$WINID"
              tmux switch-client -c "$CAND_TTY" -t "$SESSION"
              exit 0
            fi
          done < <(list_terms)

          exit 1
        '')
        (writeShellScriptBin "tmux-rofi" ''
          # Build a tag/label list of tmux sessions for kdialog --menu.
          # Tag = session name (what kdialog prints on stdout); label = shown text.
          # Dirty worktrees are marked with a trailing "*".
          ARGS=()
          while read -r name path; do
            label="$name"
            if [ -d "$path/.git" ]; then
              branch=$(${pkgs.git}/bin/git -C "$path" branch --show-current 2>/dev/null)
              dirty=$(${pkgs.git}/bin/git -C "$path" status --porcelain 2>/dev/null)
              if [ -n "$dirty" ]; then
                label="$name (#$branch) *"
              else
                label="$name (#$branch)"
              fi
            fi
            ARGS+=("$name" "$label")
          done < <(tmux list-sessions -F '#{session_name} #{pane_current_path}' 2>/dev/null)

          [ ''${#ARGS[@]} -eq 0 ] && exit 0
          SESSION=$(${pkgs.kdePackages.kdialog}/bin/kdialog --title "tmux" \
            --menu "Select a session:" "''${ARGS[@]}")
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
          ARGS=()
          while read -r p; do
            [ -n "$p" ] && ARGS+=("$p" "$p")
          done < <(find "$SRC" -mindepth 2 -type d -name .git -prune -printf '%h\n' 2>/dev/null | sed "s|^$SRC/||" | sort)

          [ ''${#ARGS[@]} -eq 0 ] && exit 0
          SELECTED=$(${pkgs.kdePackages.kdialog}/bin/kdialog --title "project" \
            --menu "Open a project:" "''${ARGS[@]}")
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
          ACTIVE=$(hyprctl activewindow -j)
          ADDR=$(echo "$ACTIVE" | jq -r '.address // empty')
          CLASS=$(echo "$ACTIVE" | jq -r '.class // empty')

          TTY=""
          SESSION=""
          if [ "$CLASS" = "${terminal}" ] && [ -n "$ADDR" ]; then
            PID=$(echo "$ACTIVE" | jq -r .pid)
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

      # Tell KRunner about the D-Bus runner...
      xdg.dataFile."krunner/dbusplugins/tmuxrunner.desktop".text = ''
        [Desktop Entry]
        Type=Service
        Name=Tmux Sessions
        Comment=Switch between tmux sessions
        Icon=utilities-terminal
        X-KDE-PluginInfo-Name=tmuxrunner
        X-KDE-PluginInfo-EnabledByDefault=true
        X-Plasma-API=DBus
        X-Plasma-DBusRunner-Service=org.peteyycz.tmuxrunner
        X-Plasma-DBusRunner-Path=/tmuxrunner
      '';

      # ...and let D-Bus start it on demand (Plasma 6 requires this .service).
      xdg.dataFile."dbus-1/services/org.peteyycz.tmuxrunner.service".text = ''
        [D-BUS Service]
        Name=org.peteyycz.tmuxrunner
        Exec=${tmuxKrunner}/bin/tmux-krunner
      '';
    };
}
