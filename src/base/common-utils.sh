#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USER_UID:-"automatic"}"
USER_GID="${USER_GID:-"automatic"}"
SET_THEME="${SET_THEME:-"true"}"
FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Fetching the latest versions of the package list..."
apt update -y

echo "Installing updates for each outdated package and dependency..."
apt upgrade -y --no-install-recommends

# Ensure apt is in non-interactive to avoid prompts
DEBIAN_FRONTEND=noninteractive

packages=(
  ca-certificates
  curl
  fontconfig
  git
  jq
  locales
  screenfetch
  sudo
  tig
  tree
  tzdata
  vim
  zip
  zsh
)
echo "Installing packages..."
apt install -y --no-install-recommends "${packages[@]}"

echo "Removing packages that are no longer required..."
apt autoremove -y

# Fix character not in range error before shell change
# https://github.com/ohmyzsh/ohmyzsh/issues/4786
if ! grep -o -E '^\s*en_US.UTF-8\s+UTF-8' /etc/locale.gen > /dev/null; then
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen  
fi

# If in automatic mode, determine if a user already exists, if not use vscode
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
  USERNAME=""
  FIRST_USER="$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)"
  if id -u ${FIRST_USER} > /dev/null 2>&1; then
      USERNAME=${FIRST_USER}
      break
  fi
  if [ "${USERNAME}" = "" ]; then
      USERNAME=vscode
  fi
elif [ "${USERNAME}" = "none" ]; then
    USERNAME=root
    USER_UID=0
    USER_GID=0
fi
# Create or update a non-root user to match UID/GID.
if id -u ${USERNAME} > /dev/null 2>&1; then
    # User exists, update if needed
    if [ "${USER_GID}" != "automatic" ] && [ "$USER_GID" != "$(id -g $USERNAME)" ]; then
        group_name="$(id -gn $USERNAME)"
        groupmod --gid $USER_GID ${group_name}
        usermod --gid $USER_GID $USERNAME
    fi
    if [ "${USER_UID}" != "automatic" ] && [ "$USER_UID" != "$(id -u $USERNAME)" ]; then
        usermod --uid $USER_UID $USERNAME
    fi
else
    # Create group
    # Determine if GID provided, if not use vscode
    if [ "${USER_GID}" = "automatic" ]; then
        groupadd $USERNAME
    else
        groupadd --gid $USER_GID $USERNAME
    fi
    # Create user
    # Determine if UID provided, if not use vscode
    if [ "${USER_UID}" = "automatic" ]; then
        useradd -s /bin/bash --gid $USERNAME -m $USERNAME
    else
        useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME
    fi
fi

# Add sudo support for non-root user
if [ "${USERNAME}" != "root" ]; then
  mkdir -p /etc/sudoers.d
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
  chmod 0440 /etc/sudoers.d/$USERNAME
fi

echo "Set default shell..."
chsh --shell /bin/zsh ${USERNAME}

if [[ ! -d "/usr/local/share/.zsh/bundle" ]]; then
  git clone https://github.com/zsh-users/antigen.git /usr/local/share/.zsh/bundle
  cat "${FEATURE_DIR}/scripts/zshrc_snippet" >> /etc/zsh/zshrc
  ln -s /usr/local/share/.zsh/bundle /etc/skel/.zsh
fi

echo "Installing powerline font..."
curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o /usr/share/fonts/"Roboto Mono for Powerline.ttf"
fc-cache -f -v
fc-list | grep "Roboto Mono for Powerline.ttf"

if [[ ! -d "/usr/local/share/.vim/bundle/Vundle.vim" ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git /usr/local/share/.vim/bundle/Vundle.vim
  cat "${FEATURE_DIR}/scripts/vimrc_snippet" >> /etc/vim/vimrc
  ln -s /usr/local/share/.vim/bundle/Vundle.vim /etc/skel/.vim
fi

if [ "${SET_THEME}" = "true" ]; then
  sed -i '/^antigen theme/s/.*/antigen theme agnoster/' /etc/zsh/zshrc
  sed -i '/^colorscheme/s/.*/colorscheme gotham256/' /etc/vim/vimrc
fi

vim +silent! +PluginInstall +qall
source /etc/zsh/zshrc
# alireza94.theme-gotham




