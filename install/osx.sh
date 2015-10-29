# Homebrew
[ -z "$(which brew)" ] &&
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "updating homebrew"
brew update

echo "installing"
brew install \
  vim neovim \
  tmux reattach-to-user-namespace \
  rabbitmq redis postgresql mysql \
  automake imagemagick \
  cscope ctags \
  python lua rust \
  the_silver_searcher ack \
  git

