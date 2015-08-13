#!/bin/bash

echo "installing dotfiles"

echo "initializing submodule(s)"
git submodule update --init --recursive

DOTFILES=$HOME/dotfiles

echo "creating symlinks"
linkables=$( ls -1 -d *.symlink )
for file in $linkables ; do
    target="$HOME/.$( basename $file ".symlink" )"
    echo "creating symlink for $file"
    ln -s $DOTFILES/$file $target
done

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

