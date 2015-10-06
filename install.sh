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

# plug.vim
if [ ! -e ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
      https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# git-prompt
if [ ! -e ~/.git-prompt.sh ]; then
  wget https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh -O ~/.git-prompt.sh
fi

# node version manager
if [ ! -e ~/.nvm ]; then
  wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.26.1/install.sh | bash
fi

if [ $(uname -s) = 'Darwin' ]; then
  # Homebrew
  [ -z "$(which brew)" ] &&
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  echo "Updating homebrew"
  brew update
  brew install \
    vim neovim \
    tmux reattach-to-user-namespace \
    rabbitmq redis postgresql mysql \
    automake imagemagick \
    cscope ctags \
    python lua rust \
    the_silver_searcher ack \
    git
  brew install macvim
fi

