{ config, pkgs, lib, ... }:

let
  colorsLib = import ./colors.nix { inherit lib; };
  colors = colorsLib.palette;
in
{
  imports = [
    ./common-apps.nix
    ./hyprland.nix
    ./notes.nix
    ./git.nix
    ./claude-code.nix
  ];

  home.stateVersion = "25.05";

  home.file.".local/share/backgrounds/default.jpg".source =
    pkgs.fetchurl (import ../wallpaper.nix);

  home.file.".config/chrome-flags.conf".text = ''
    --force-dark-mode
    --enable-features=WebUIDarkMode
  '';

  programs.peon-ping = {
    enable = true;
    installPacks = [ "peon" ];
    settings = {
      enabled = true;
      desktop_notifications = true;
      volume = 0.5;
      default_pack = "peon";
    };
  };

  home.packages = with pkgs; [
    networkmanagerapplet

    gcc
    gnumake

    nodejs_24
    go

    nixd
    nixfmt
    coturn

    nerd-fonts.victor-mono
    pandoc

    kubectl
    kubernetes-helm

    awscli2
    opentofu
    terraform
    terragrunt
    pomerium-cli
    vault
    mongosh
    mongodb-tools

    mediainfo
    imv
    mpv
    spotify

    gh
    ghq
    piper-tts

    libwebp
    btop
    fd
    eza

    postgresql

    ruby
    kamal

    beam.packages.erlang_27.erlang
    beam.packages.erlang_27.elixir_1_18
    inotify-tools
    watchman

    (writeShellScriptBin "tmux-rofi" ''
      # Build list of sessions with git branch info
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

      SELECTED=$(echo "$ENTRIES" | rofi -dmenu -markup-rows -p "tmux" -theme-str 'window {width: 30%;}')
      [ -z "$SELECTED" ] && exit 0
      SESSION=$(echo "$SELECTED" | awk '{print $1}')
      [ -z "$SESSION" ] && exit 0

      if ! tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux new-session -d -s "$SESSION"
      fi

      # Check if focused window is a foot terminal running tmux
      ACTIVE_JSON=$(hyprctl activewindow -j)
      FOCUSED_APP=$(echo "$ACTIVE_JSON" | jq -r '.class // empty')
      if [ "$FOCUSED_APP" = "foot" ]; then
        FOCUSED_PID=$(echo "$ACTIVE_JSON" | jq -r '.pid')
        CHILD_PID=$(${pkgs.procps}/bin/pgrep -P "$FOCUSED_PID" | head -1)
        if [ -n "$CHILD_PID" ]; then
          TTY="/dev/$(ps -o tty= -p "$CHILD_PID" | tr -d ' ')"
          if tmux list-clients -F '#{client_tty}' | grep -qx "$TTY"; then
            tmux switch-client -c "$TTY" -t "$SESSION"
            exit 0
          fi
        fi
      fi

      # No terminal focused or not running tmux — open new foot with tmux
      exec foot tmux attach -t "$SESSION"
    '')
    (writeShellScriptBin "tmuxn" ''tmux new-session -s "$(basename "$PWD")"'')
    (writeShellScriptBin "run-server" ''
      if [ -f package.json ]; then
        if grep -q '"dev"' package.json; then
          exec npm run dev
        elif grep -q '"start"' package.json; then
          exec npm start
        fi
      elif [ -f mix.exs ]; then
        exec mix phx.server
      fi
    '')
    (writeShellScriptBin "start-accessories" ''
      if [ -f docker-compose.yml ] || [ -f docker-compose.yaml ]; then
        docker compose up -d
      fi
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

  home.sessionVariables.EDITOR = "vim";

  home.file.".npmrc".text = ''
    prefix=~/.local
  '';
  home.sessionPath = [ "$HOME/.local/bin" ];

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      sansSerif = [ "Open Runde" "Symbols Nerd Font" ];
      monospace = [ "VictorMono Nerd Font Mono" "Symbols Nerd Font" ];
    };
  };

  services.network-manager-applet.enable = true;

  programs.difftastic.enable = true;
  programs.ripgrep.enable = true;

  programs.fzf.enable = true;

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
      set -g status-style bg=#282828
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

      # Gruvbox Dark pane borders
      set -g pane-border-style fg=#3c3836
      set -g pane-active-border-style fg=#665c54

      # Gruvbox Dark selection highlight
      set -g mode-style "fg=#ebdbb2,bg=#504945"
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "nix-env.fish";
        src = pkgs.fetchFromGitHub {
          owner = "lilyball";
          repo = "nix-env.fish";
          rev = "00c6cc762427efe08ac0bd0d1b1d12048d3ca727";
          sha256 = "1hrl22dd0aaszdanhvddvqz3aq40jp9zi2zn0v1hjnf7fx4bgpma";
        };
      }

    ];

    shellAliases = {
      # Git aliases
      gc = "git commit";
      gco = "git checkout";
      gp = "git push";
      gl = "git pull";
      gpf = "git push --force-with-lease";
      gst = "git status";
      gd = "git diff";
      gds = "git diff --staged";
      ga = "git add";
      gaa = "git add --all";
      grbc = "git rebase --continue";
      grba = "git rebase --abort";
      gq = "git quick";

      # Other aliases
      l = "eza -la --icons --group-directories-first";
      lt = "eza --tree --icons -L 2";
    };

    interactiveShellInit = ''
      # Set fish greeting
      set -U fish_greeting "🐟"

      # Add paths
      # fish_add_path (go env GOBIN)
      fish_add_path "$HOME/.local/bin"

      set -g fish_cursor_default block
      set -g fish_cursor_insert block

      bind \cg edit_command_buffer

      set -gx GOPATH "$HOME/Code"
      set -gx GHQ_ROOT "$GOPATH/src"

      if test -f ~/.config/fish/config.local.fish
        source ~/.config/fish/config.local.fish
      end
    '';
  };

  # Enable Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings.aws.disabled = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };


  home.pointerCursor = {
    name = "macOS";
    package = pkgs.apple-cursor;
    size = 24;
    gtk.enable = true;
  };

  gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.theme = null;
    font = {
      name = "Open Runde";
      size = 11;
    };
    iconTheme = {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.gruvbox-plus-icons;
    };
    gtk4.extraCss = ''
      @define-color window_bg_color ${colors.bgHard};
      @define-color window_fg_color ${colors.fg};
      @define-color view_bg_color ${colors.bg};
      @define-color view_fg_color ${colors.fg};
      @define-color headerbar_bg_color ${colors.bgHard};
      @define-color headerbar_fg_color ${colors.fg};
      @define-color headerbar_border_color ${colors.bg1};
      @define-color headerbar_backdrop_color ${colors.bgHard};
      @define-color sidebar_bg_color ${colors.bgHard};
      @define-color sidebar_fg_color ${colors.fg3};
      @define-color sidebar_backdrop_color ${colors.bgHard};
      @define-color secondary_sidebar_bg_color ${colors.bg};
      @define-color secondary_sidebar_fg_color ${colors.fg3};
      @define-color card_bg_color ${colors.bg1};
      @define-color card_fg_color ${colors.fg};
      @define-color popover_bg_color ${colors.bg};
      @define-color popover_fg_color ${colors.fg};
      @define-color dialog_bg_color ${colors.bg};
      @define-color dialog_fg_color ${colors.fg};
      @define-color accent_bg_color ${colors.orange};
      @define-color accent_fg_color ${colors.bgHard};
      @define-color accent_color ${colors.yellow};
      @define-color destructive_bg_color ${colors.redDark};
      @define-color destructive_fg_color ${colors.fg};
      @define-color destructive_color ${colors.red};
      @define-color success_bg_color ${colors.greenDark};
      @define-color success_color ${colors.green};
      @define-color warning_bg_color ${colors.yellowDark};
      @define-color warning_color ${colors.yellow};
      @define-color error_bg_color ${colors.redDark};
      @define-color error_color ${colors.red};
    '';
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-animations = false;
      icon-theme = "Gruvbox-Plus-Dark";
      font-name = "Open Runde 11";
      document-font-name = "Open Runde 11";
    };
    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
    };
    "org/gtk/settings/file-chooser" = {
      show-hidden = true;
    };
    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "com.google.Chrome.desktop";
      "x-scheme-handler/http" = "com.google.Chrome.desktop";
      "x-scheme-handler/https" = "com.google.Chrome.desktop";
      "x-scheme-handler/about" = "com.google.Chrome.desktop";
      "application/xhtml+xml" = "com.google.Chrome.desktop";
    };
  };
}
