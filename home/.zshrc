source $HOME/antigen.zsh

antigen use oh-my-zsh
antigen bundle git
antigen bundle asdf
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle chrissicool/zsh-256color
antigen bundle agkozak/zsh-z
antigen bundle unixorn/fzf-zsh-plugin@main

antigen apply

bindkey -e

export EDITOR=vim
export VISUAL=vim
export GHQ_ROOT="$HOME/Code/src"

alias tmuxn='tmux new-session -t $(basename $PWD)';
alias vim='nvim';

eval "$(starship init zsh)"
