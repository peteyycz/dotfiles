{ ... }:
{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      programs.tmux = {
        enable = true;
        terminal = "tmux-256color";
        baseIndex = 1;
        keyMode = "vi";
        mouse = true;
        plugins = with pkgs.tmuxPlugins; [
          sensible
          yank
          vim-tmux-navigator
          better-mouse-mode
        ];
        extraConfig = ''
          set -g allow-passthrough on
          set -g cursor-style block
          set -g status on
          set -g status-position bottom
          set -g status-right ""
          set -g status-left "[#S] "
          set -g status-left-length 50

          # Status styling references the terminal's ANSI palette (colour0-15)
          # instead of hardcoded hex, so it follows whatever theme the terminal
          # is using. `bg=default` inherits the terminal background; the active
          # window pops as a pill in the palette's yellow (colour3).
          set -g status-style "bg=default,fg=colour7"
          set -g window-status-format " #I:#W "
          set -g window-status-current-format " #I:#W "
          set -g window-status-style "bg=default,fg=colour8"
          set -g window-status-current-style "bg=colour3,fg=colour0,bold"
          set -g window-status-activity-style "fg=colour1"
          set -g window-status-separator ""
          set -g message-style "bg=colour8,fg=colour7"
          set -g pane-border-style "fg=colour8"
          set -g pane-active-border-style "fg=colour3"
          set -g mode-style "bg=colour3,fg=colour0"
          setw -g pane-base-index 1
          set -g status-keys vi
          setw -g clock-mode-style 12

          unbind i

          # automatically renumber tmux windows
          set -g renumber-windows on

          bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
          bind w neww
          bind m choose-window

          # fzf popups: session switcher, project picker, scripts runner.
          # -T sets the popup border title (top edge) to the hostname so it is
          # always clear which host this tmux server is on.
          bind a display-popup -E -T " #h " -w 50% -h 40% "tmux-switch"
          bind p display-popup -E -T " #h " -w 50% -h 40% "tmux-project"
          bind P display-popup -E -T " #h " -w 40% -h 40% "tmux-scripts"

          bind c kill-pane
          bind t set status
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R
          bind ^h resize-pane -L
          bind ^j resize-pane -D
          bind ^k resize-pane -U
          bind ^l resize-pane -R
          bind C-k send-keys C-l
          bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"
          bind v split-window -h
          bind s split-window
          bind : command-prompt
          bind Escape copy-mode

          unbind-key -n MouseDown3Pane

          set -g set-titles on
          set -g set-titles-string 'Linux is my IDE'
          set -g repeat-time 100
          setw -g alternate-screen on

          set -g display-panes-time 1000
          setw -g automatic-rename on
        '';
      };
    };
}
