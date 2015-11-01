alias l="ls -la"

# For configs
# -----------
alias csh="vim ~/.bash_profile"
alias cvim="vim ~/.vimrc"
alias ctmux="vim ~/.tmux.conf"

# General
# -------
alias so='source'

# Tmux related
# ------------
alias tls="tmux ls"
alias ta="tmux attach"

# Copy public ssh key
# -------------------
alias cpssh="cat ~/.ssh/id_rsa.pub | pbcopy"

# Editors
# -------
alias subl="/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl"
code () { VSCODE_CWD="$PWD" open -n -b "com.microsoft.VSCode" --args $* ;}

# Tmux
# ----
alias tks='tmux kill-session'
alias tls='tmux ls'
alias ta='tmux attach'

# Typo-protector
alias got='git'
alias vom='vim'
