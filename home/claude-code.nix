{ ... }:

let
  notifyCommand = body: ''bash -c 'SESSION=$(tmux display-message -p "#S" 2>/dev/null || echo "claude"); (ACTION=$(notify-send --app-name="Claude Code" --icon="/home/peteyycz/.openpeon/docs/peon-icon.png" --action="open=Open" --wait "Claude Code — $SESSION" "${body}"); [ "$ACTION" = "open" ] && hyprctl dispatch focuswindow "class:foot" && tmux switch-client -t "$SESSION") </dev/null >/dev/null 2>&1 &' '';

  notifyHook = body: {
    matcher = "";
    hooks = [
      {
        type = "command";
        command = notifyCommand body;
        async = true;
      }
    ];
  };

  peonHook = {
    matcher = "";
    hooks = [
      {
        type = "command";
        command = "/home/peteyycz/.openpeon/peon.sh";
        timeout = 10;
        async = true;
      }
    ];
  };
in
{
  home.file.".claude/settings.json".text = builtins.toJSON {
    hooks = {
      Stop = [ (notifyHook "Task complete") peonHook ];
      Notification = [ (notifyHook "Needs your attention") peonHook ];
      SessionEnd = [ (notifyHook "Session ended") peonHook ];
      PermissionRequest = [ (notifyHook "Needs permission") peonHook ];
    };
    skipAutoPermissionPrompt = true;
    permissions.defaultMode = "auto";
  };
}
