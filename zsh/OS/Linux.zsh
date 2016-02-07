# Swap control and escape
setxkbmap -option ctrl:nocaps
xcape

# BSD like copy
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

# Linuxbrew config
export PATH="$HOME/.linuxbrew/bin:$PATH"
export MANPATH="$HOME/.linuxbrew/bin:$PATH"
