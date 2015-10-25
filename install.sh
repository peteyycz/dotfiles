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

# Run OSX installer
echo "installing OSX utilities"
if [ $(uname -s) = 'Darwin' ]; then
  sh $DOTFILES/install/osx.sh
fi

# Run Linux installer
echo "installing linux utilities"
if [ $(uname -s) = 'Linux' ]; then
  sh $DOTFILES/install/osx.sh
fi
