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

          # status styling — Gruvbox Material to match the foot palette.
          # `bg=default` lets the status inherit foot's translucent background;
          # the active window pops as a warm gruvbox-yellow pill.
          set -g status-style "bg=default,fg=#a89984"
          set -g window-status-format " #I:#W "
          set -g window-status-current-format " #I:#W "
          set -g window-status-style "bg=default,fg=#a89984"
          set -g window-status-current-style "bg=#d8a657,fg=#282828,bold"
          set -g window-status-activity-style "fg=#ea6962"
          set -g window-status-separator ""
          set -g message-style "bg=#3c3836,fg=#d4be98"
          set -g pane-border-style "fg=#504945"
          set -g pane-active-border-style "fg=#d8a657"
          set -g mode-style "bg=#d8a657,fg=#282828"
          setw -g pane-base-index 1
          set -g status-keys vi
          setw -g clock-mode-style 12

          unbind i

          # automatically renumber tmux windows
          set -g renumber-windows on

          bind-key -T copy-mode-vi 'v' send-keys -X begin-selection
          bind w neww
          bind m choose-window

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
