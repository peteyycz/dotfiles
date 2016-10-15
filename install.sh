#!/bin/bash

echo "installing dotfiles"

# In case of submodules
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

# Install node version manager
echo "installing nvm"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.32.0/install.sh | bash

echo "installing plug.vim"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
echo "creating nvim symlink"
ln -s $DOTFILES/vim ~/.vim

# NeoVim CTRL + H
infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti
tic $TERM.ti
