# Commands to run in interactive sessions can go here
if status is-interactive
    eval "$(starship init fish)"

    set -U fish_greeting "🐟"

    # Variables {
    set -x VISUAL vim

    # Source asdf fish integration if it exists
    mise activate fish | source

    set -x GOPATH "$HOME/Code"
    fish_add_path $GOPATH/bin
    set -x GHQ_ROOT "$GOPATH/src"

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
    alias gq="git quick"

    alias tmuxn='tmux new-session -t $(basename $PWD)'
    alias vim='nvim'

    alias l="ls -la"
    # }

    fish_add_path (go env GOBIN)

    fish_add_path "$HOME/.local/bin"

    switch (uname)
        case Darwin
            source $HOME/.local/bin/env.fish
            fish_add_path /opt/homebrew/bin
    end

    # Source local configuration if it exists
    if test -f ~/.config/fish/config.local.fish
        source ~/.config/fish/config.local.fish
    end
end
