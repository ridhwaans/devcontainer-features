#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

USERNAME="${USERNAME:-"ridhwaans"}"
SET_THEME="${SET_THEME:-"true"}"
FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source ./scripts/helpers.sh

echo "Fetching the latest versions of the package list..."
apt update -y

echo "Installing updates for each outdated package and dependency..."
apt upgrade -y

# Ensure apt is in non-interactive to avoid prompts
DEBIAN_FRONTEND=noninteractive

packages=(
  curl
  sudo
  git
  jq
  screenfetch
  tig
  tree
  tzdata
  vim
  zip
  zsh
)
echo "Installing packages..."
apt install -y "${packages[@]}"

echo "Removing packages that are no longer required..."
apt autoremove

# Install fix for character not in range error before shell change
# https://github.com/ohmyzsh/ohmyzsh/issues/4786
apt install -y language-pack-en
update-locale

echo "Setting up user shell..."
chsh --shell $(which zsh) ${USERNAME}

# Verify
$(which zsh)
grep ${USERNAME} /etc/passwd

# Add sudo support for non-root user
if [ "${USERNAME}" != "root" ]; then
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
  chmod 0440 /etc/sudoers.d/$USERNAME
fi

plugin_manager_exists ~/.zsh/bundle
if [ $? -ne 0 ]; then
  git clone https://github.com/zsh-users/antigen.git ~/.zsh/bundle
  cat "${FEATURE_DIR}/scripts/zshrc_snippet.sh" >> "~/.zshrc"
fi

echo "Installing powerline font..."
curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o $HOME/.local/share/fonts/"Roboto Mono for Powerline.ttf"
fc-cache -f -v
fc-list | grep "Roboto Mono for Powerline.ttf"

plugin_manager_exists ~/.vim/bundle/Vundle.vim
if [ $? -ne 0 ]; then
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
  cat "${FEATURE_DIR}/scripts/vimrc_snippet.sh" >> "~/.vimrc"
fi

if [ "${SET_THEME}" = "true" ]; then
  sed -i '/^antigen theme/s/.*/antigen theme agnoster/' ~/.vimrc
  sed -i '/^colorscheme/s/.*/colorscheme gotham/' ~/.vimrc
fi

vim +silent! +PluginInstall +qall
source ~/.zshrc
# alireza94.theme-gotham




