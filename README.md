# My dotfiles

ENJOY!!! :)

# Prerequisites

- fish
- fisher
- stow
- ripgrep
- fzf
- asdf
- tmux
- ghq
- lazygit
- difftastic
- neovim
- doom emacs (optional)

## Installing

```sh
stow -t ~ common
```

## Removing
```sh
stow -D -t ~ common
```

## Doom Emacs

After running `stow`, the Doom Emacs config will be linked to `~/.config/doom/`.

To use it, first install Doom Emacs:
```sh
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install
```

Then sync the config:
```sh
doom sync
```
