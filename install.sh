#!/bin/bash

echo "installing dotfiles"

# In case of submodules
echo "initializing submodule(s)"
git submodule update --init --recursive

DOTFILES=$HOME/.dotfiles

echo "creating symlinks"
linkables=$( ls -1 -d *.symlink )
for file in $linkables ; do
    target="$HOME/.$( basename $file ".symlink" )"
    echo "creating symlink for $file"
    ln -s $DOTFILES/$file $target
done
