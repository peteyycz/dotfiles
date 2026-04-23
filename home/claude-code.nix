{ ... }:

let
  notifyCommand = body: ''bash -c 'SESSION=$(tmux display-message -p "#S" 2>/dev/null || echo "claude"); (ACTION=$(dunstify -a "Claude Code" -A "open,Open" "Claude Code — '$SESSION'" "${body}"); [ "$ACTION" = "open" ] && swaymsg "[app_id=foot] focus" && tmux switch-client -t "$SESSION") &' '';

  notifyHook = body: {
    matcher = "";
    hooks = [
      {
        type = "command";
        command = notifyCommand body;
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
