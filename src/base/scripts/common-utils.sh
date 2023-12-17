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
    USERNAME=${FIRST_USER}\
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

zsh_rc_snippet=$(cat << 'EOF'
# General
ADOTDIR=/usr/local/share/.zsh/bundle
ANTIGEN_LOG=${ADOTDIR}/antigen.log

# Customization
ANTIGEN_CACHE=${ADOTDIR}/init.zsh
ANTIGEN_COMPDUMP=${ADOTDIR}/.zcompdump
ANTIGEN_BUNDLES=${ADOTDIR}/bundles
ANTIGEN_LOCK=${ADOTDIR}/.lock
ANTIGEN_DEBUG_LOG=${ADOTDIR}/debug.log

source ${ADOTDIR}/bin/antigen.zsh

# Load the oh-my-zsh's library.
antigen use oh-my-zsh

# Load the theme.
antigen theme agnoster

# Tell Antigen that you're done.
antigen apply
EOF
)

echo "Set default shell..."
chsh --shell /bin/zsh ${USERNAME}

if [[ ! -d "/usr/local/share/.zsh/bundle" ]]; then
  git clone https://github.com/zsh-users/antigen.git /usr/local/share/.zsh/bundle
  updaterc "${zsh_rc_snippet}"
  ln -s /usr/local/share/.zsh/bundle /etc/skel/.zsh
fi

echo "Installing powerline font..."
curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o /usr/share/fonts/"Roboto Mono for Powerline.ttf"
fc-cache -f -v
fc-list | grep "Roboto Mono for Powerline.ttf"


vim_rc_snippet=$(cat << 'EOF'
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=/usr/local/share/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
Plugin 'whatyouhide/vim-gotham'
" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

try
  colorscheme gotham256
catch /^Vim\%((\a\+)\)\=:E185/
endtry
EOF
)

if [[ ! -d "/usr/local/share/.vim/bundle/Vundle.vim" ]]; then
  git clone https://github.com/VundleVim/Vundle.vim.git /usr/local/share/.vim/bundle/Vundle.vim
  updaterc "/etc/vim/vimrc" "${vim_rc_snippet}"
  ln -s /usr/local/share/.vim/bundle/Vundle.vim /etc/skel/.vim
fi

if [ "${SET_THEME}" = "true" ]; then
  sed -i '/^antigen theme/s/.*/antigen theme agnoster/' /etc/zsh/zshrc
  sed -i '/^colorscheme/s/.*/colorscheme gotham256/' /etc/vim/vimrc
  # alireza94.theme-gotham
fi

vim +silent! +PluginInstall +qall
source /etc/zsh/zshrc