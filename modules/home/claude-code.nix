{ ... }:
{
  # Requires home/peon-ping.nix to be loaded (installs ~/.openpeon/peon.sh).
  flake.modules.homeManager.claude-code =
    { config, pkgs, ... }:
    let
      peonDir = "${config.home.homeDirectory}/.openpeon";
      icon = "${peonDir}/docs/peon-icon.png";

      # `--wait` blocks until the notification is dismissed, and Plasma keeps
      # actionable ones in history indefinitely — undismissed ones used to
      # linger until systemd SIGKILLed them 90s into shutdown. `timeout` caps
      # how long the Open button stays live, and with it the stray process.
      linuxNotify =
        body:
        ''bash -c 'SESSION=$(tmux display-message -p "#S" 2>/dev/null || echo "claude"); (ACTION=$(timeout 30 notify-send --app-name="Claude Code" --icon="${icon}" --action="open=Open" --wait "Claude Code — $SESSION" "${body}"); [ "$ACTION" = "open" ] && tmux-focus "$SESSION") </dev/null >/dev/null 2>&1 &' '';

      # macOS has no notify-send, and terminal-notifier has no counterpart to
      # its --action/--wait round-trip, so the banner is fire-and-forget: no
      # Open button, because tmux-focus is built on kdotool and does not exist
      # here. -group makes a repeat hook replace the previous banner instead of
      # stacking in Notification Center. Referenced by store path rather than
      # PATH, since apps.nix (which supplies libnotify on Linux) is not loaded
      # on Darwin.
      darwinNotify =
        body:
        ''bash -c 'SESSION=$(tmux display-message -p "#S" 2>/dev/null || echo "claude"); ${pkgs.terminal-notifier}/bin/terminal-notifier -title "Claude Code — $SESSION" -message "${body}" -appIcon "${icon}" -group "claude-code-$SESSION" </dev/null >/dev/null 2>&1 &' '';

      notifyCommand = if pkgs.stdenv.hostPlatform.isDarwin then darwinNotify else linuxNotify;

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
            command = "${peonDir}/peon.sh";
            timeout = 10;
            async = true;
          }
        ];
      };
    in
    {
      home.file.".claude/CLAUDE.md".text = ''
        # Global instructions

        ## Creating pull requests

        - **Never co-sign commits.** Do not add a `Co-Authored-By: Claude` trailer (or any
          Claude/Anthropic attribution) to commit messages. Commits are authored by the user alone.
        - **Never add the "Generated with Claude Code" footer** to PR bodies.
        - **Keep PR descriptions very brief — about 2 lines.** State what changed and why it
          matters. Detail belongs in the commit message, the ticket, or review comments, not
          the PR body.
        - **Branch before committing.** Never commit directly to the repo's default branch.
        - **Name branches after the ticket:** `<TICKET-ID>-<short-kebab-summary>`, e.g.
          `OKT-2102-antifraud-hmac-fix`. Match the repo's existing branch naming if it differs.
        - **Commit messages are a single line.** Subject only — no body, no bullet lists,
          no explanation of rationale. If it needs more than one line, it needs a smaller
          commit. Context belongs in the ticket or in review.
        - **Prefix commit subjects with the ticket ID** when working on one, matching the
          repo's existing commit style.
        - Open the PR against the repo's base branch (in Oktogon-Media repos this is
          `development`, not `main`).
      '';

      home.file.".claude/settings.json".text = builtins.toJSON {
        hooks = {
          Stop = [
            (notifyHook "Task complete")
            peonHook
          ];
          Notification = [
            (notifyHook "Needs your attention")
            peonHook
          ];
          SessionEnd = [
            (notifyHook "Session ended")
            peonHook
          ];
          PermissionRequest = [
            (notifyHook "Needs permission")
            peonHook
          ];
        };
        skipAutoPermissionPrompt = true;
        permissions.defaultMode = "auto";
      };
    };
}
