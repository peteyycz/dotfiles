#!/bin/bash

# Installing ZPlug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

chsh -s $(which zsh)

# Installing Rustup
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Installing dotfiles"

DOTFILES=$HOME/.dotfiles

echo "creating symlinks"
linkables=$( ls -1 -d *.symlink )
for file in $linkables ; do
    target="$HOME/.$( basename $file ".symlink" )"
    echo "creating symlink for $file"
    ln -s $DOTFILES/$file $target
done
