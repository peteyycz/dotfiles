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

# Install vim package manager
echo "installing vim plug"
if [ ! -e ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install node version manager
echo "installing nvm"
if [ ! -e ~/.nvm ]; then
  wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash
fi

# Run installer
sh $DOTFILES/install/`uname -s`.sh

# Change default shell to ZSH
echo "changing default shell to zsh"
chsh $(which zsh)

