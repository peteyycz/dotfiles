{ ... }:
{
  flake.modules.homeManager.fish = { pkgs, ... }: {
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
  };
}
