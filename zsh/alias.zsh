alias l="k -a"

# For configs
# -----------
alias czsh="$EDITOR ~/.zshrc"
alias cvim="$EDITOR ~/.vimrc"
alias ci3="$EDITOR ~/.config/i3/config"
alias ctmux="$EDITOR ~/.tmux.conf"

# General
# -------
alias so=source
# Use neovim as vim
if hash nvim 2>/dev/null; then
  alias vim="nvim"
fi

# Copy public ssh key
# -------------------
alias cpssh="cat ~/.ssh/id_rsa.pub | pbcopy"

# Typo-protector
alias got=git

alias mux=tmuxinator
