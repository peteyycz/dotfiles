{ config, pkgs, ... }:

{
  home.username = "peteyycz";
  home.homeDirectory = "/home/peteyycz";

  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    nixd
    nixfmt-rfc-style

    nerd-fonts.victor-mono
    nerd-fonts.symbols-only
    inter

    kubectl
    kubernetes-helm

    ghq
    claude-code

    (writeShellScriptBin "zellij-session-picker" (builtins.readFile ./scripts/zellij-session-picker))
  ];

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

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

  programs.tmux.enable = true;

  programs.zellij = {
    enable = true;
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
    settings = {
      legacy_version_file = true;
      idiomatic_version_file_enable_tools = [ "node" ];
    };
  };
}
