echo "installing"
pacman -Sy install \
  vim neovim \
  tmux reattach-to-user-namespace \
  rabbitmq redis postgresql mysql \
  automake imagemagick \
  cscope ctags \
  the_silver_searcher \
  git

