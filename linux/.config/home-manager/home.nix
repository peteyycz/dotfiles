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

    nerd-fonts.victor-mono
    nerd-fonts.symbols-only
    inter
    pandoc

    kubectl
    kubernetes-helm

    ghq
    claude-code

    beam.packages.erlang_27.erlang
    beam.packages.erlang_27.elixir_1_18

    (writeShellScriptBin "tmuxn" ''tmux new-session -s "$(basename "$PWD")"'')
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
    terminal = "screen";
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
      better-mouse-mode
      tmux-fzf
    ];
    extraConfig = ''
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
      bind a choose-session
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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-animations = false;
    };
  };
}
