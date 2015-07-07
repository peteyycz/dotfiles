echo "installing dotfiles"

echo "initializing submodule(s)"
git submodule update --init --recursive

source install/link.sh

echo "configuring zsh as default shell"
chsh -s $(which zsh)
