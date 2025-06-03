# Commands to run in interactive sessions can go here
if status is-interactive
    eval "$(starship init fish)"

    # Variables {
    set -x EDITOR vim
    set -x VISUAL vim
    set -x GOPATH "$HOME/Code"
    set -x GHQ_ROOT "$GOPATH/src"
    # }

    # Alias {
    alias gc="git commit"
    alias gco="git checkout"
    alias gp="git push"
    alias gl="git fetch"
    alias gst="git status"
    alias gd="git diff"
    alias gaa="git add --all"

    alias tmuxn='tmux new-session -t $(basename $PWD)';
    alias vim='nvim';

    alias l="ls -la"
    # }

    fish_add_path (go env GOBIN)
end
