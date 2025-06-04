# Commands to run in interactive sessions can go here
if status is-interactive
    eval "$(starship init fish)"

    set -U fish_greeting "🐟"

    # Variables {
    set -x EDITOR vim
    set -x VISUAL vim
    set -x GHQ_ROOT "$GOPATH/src"

    set -gx ASDF_DIR /opt/asdf-vm
    set -gx ASDF_DATA_DIR $HOME/.asdf

    # Add asdf shims to PATH
    fish_add_path $ASDF_DATA_DIR/shims

    # Add asdf bin to PATH
    fish_add_path $ASDF_DIR/bin

    set -x GOPATH "$HOME/Code"
    fish_add_path $GOPATH/bin

    alias gc="git commit"
    alias gco="git checkout"
    alias gp="git push"
    alias gl="git pull"
    alias gpf="git push --force-with-lease"
    alias gst="git status"
    alias gd="git diff"
    alias gds="git diff --staged"
    alias gaa="git add --all"
    alias grbc="git rebase --continue"
    alias grba="git rebase --abort"

    alias tmuxn='tmux new-session -t $(basename $PWD)';
    alias vim='nvim';

    alias l="ls -la"
    # }

    fish_add_path (go env GOBIN)

    switch (uname)
      case Darwin
        fish_add_path /opt/homebrew/bin
    end
end
