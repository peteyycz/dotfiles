{ config, pkgs, ... }:

{
  home.username = "peteyycz";
  home.homeDirectory = "/home/peteyycz";

  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    gcc
    gnumake

    nixd
    nixfmt-rfc-style
    coturn

    nerd-fonts.caskaydia-mono
    nerd-fonts.symbols-only
    pandoc

    kubectl
    kubernetes-helm
    (stdenv.mkDerivation rec {
      pname = "lazykube";
      version = "0.10.3";
      src = fetchurl {
        url = "https://github.com/TNK-Studio/lazykube/releases/download/v${version}/lazykube_linux_amd64.tar.gz";
        sha256 = "sha256-KFR3f6O4EBlfm9ynOgoi1awN4MCcJImO0U4Jd9+6WTw=";
      };
      sourceRoot = "lazykube_linux_amd64";
      dontFixup = true;
      installPhase = ''
        install -Dm755 lazykube $out/bin/lazykube
      '';
    })
    awscli2

    opentofu
    terraform
    terragrunt
    pomerium-cli
    mongosh

    mediainfo

    gh
    ghq
    vault
    claude-code
    piper-tts

    postgresql

    ruby
    kamal

    beam.packages.erlang_27.erlang
    beam.packages.erlang_27.elixir_1_18

    (writeShellScriptBin "tmux-rofi" ''
      # Build list of sessions with git branch info
      ENTRIES=$(tmux list-sessions -F '#{session_name} #{pane_current_path}' 2>/dev/null | while read -r name path; do
        if [ -d "$path/.git" ]; then
          branch=$(${pkgs.git}/bin/git -C "$path" branch --show-current 2>/dev/null)
          dirty=$(${pkgs.git}/bin/git -C "$path" status --porcelain 2>/dev/null)
          if [ -n "$dirty" ]; then
            echo "$name <span color='#eb6f92'>(#$branch)</span>"
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
      FOCUSED_APP=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .app_id // empty')
      if [ "$FOCUSED_APP" = "foot" ]; then
        FOCUSED_PID=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .pid')
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

  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;
  programs.difftastic.enable = true;
  programs.ripgrep.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;

    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
  };

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
      set -g status-position top
      set -g status-right ""
      set -g status-left "[#S] "
      set -g status-left-length 50
      set -g status-style bg=#2a273f
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

      set -g set-titles on
      set -g set-titles-string 'Linux is my IDE'
      set -g repeat-time 100
      setw -g alternate-screen on

      set -g display-panes-time 1000
      setw -g automatic-rename on

      # Rose Pine Moon pane borders
      set -g pane-border-style fg=#393552
      set -g pane-active-border-style fg=#56526e

      # Rose Pine Moon selection highlight
      set -g mode-style "fg=#e0def4,bg=#44415a"
    '';
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "z";
        src = pkgs.fetchFromGitHub {
          owner = "jethrokuan";
          repo = "z";
          rev = "067e867debee59aee231e789fc4631f80fa5788e";
          sha256 = "sha256-emmjTsqt8bdI5qpx1bAzhVACkg0MNB/uffaRjjeuFxU=";
        };
      }
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
      l = "ls -la";
    };

    interactiveShellInit = ''
      # Set fish greeting
      set -U fish_greeting "🐟"

      # Add paths
      # fish_add_path (go env GOBIN)
      fish_add_path "$HOME/.local/bin"

      set -g fish_cursor_default block
      set -g fish_cursor_insert block

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
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    globalConfig.settings = {
      legacy_version_file = true;
      idiomatic_version_file_enable_tools = [ "node" ];
    };
  };

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-animations = false;
      icon-theme = "Papirus-Dark";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "com.google.Chrome.desktop";
      "x-scheme-handler/http" = "com.google.Chrome.desktop";
      "x-scheme-handler/https" = "com.google.Chrome.desktop";
    };
  };
}
