echo "installing dotfiles"

echo "initializing submodule(s)"
git submodule update --init --recursive

source install/link.sh

echo "brewing all the things"
source scripts/brew.sh

echo "updating OSX settings"
source scripts/osx.sh

echo "installing node (from nvm)"
nvm install stable
nvm alias default stable

echo "configuring zsh as default shell"
chsh -s $(which zsh)
