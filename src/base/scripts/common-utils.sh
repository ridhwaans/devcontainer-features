#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source $(dirname $0)/helpers.sh

USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
UPDATE_RC="${UPDATERC:-"true"}"
SET_THEME="${SETTHEME:-"true"}"
VUNDLE_DIR="${VUNDLEINSTALLPATH:-"/usr/local/share/.vim/bundle/Vundle.vim"}"
ANTIGEN_DIR="${ANTIGENINSTALLPATH:-"/usr/local/share/.zsh/bundle"}"

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

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
  unzip
  vim
  zip
  zsh
)

# Install the list of packages
apt update -y
apt install -y --no-install-recommends "${packages[@]}"

# Get to latest versions of all packages
apt upgrade -y --no-install-recommends
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

if [[ ! -d "$ANTIGEN_DIR" ]]; then
  # Create antigen group
  if ! cat /etc/group | grep -e "^antigen:" > /dev/null 2>&1; then
      groupadd -r antigen
  fi
  usermod -a -G antigen ${USERNAME}

  git clone https://github.com/zsh-users/antigen.git ${ANTIGEN_DIR}
  chown -R "root:antigen" "${ANTIGEN_DIR}"
  chmod -R g+rws "${ANTIGEN_DIR}"
  ln -s ${ANTIGEN_DIR} /etc/skel/.zsh
fi

echo "Installing powerline font..."
curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o /usr/share/fonts/"Roboto Mono for Powerline.ttf"
fc-cache -f -v
fc-list | grep "Roboto Mono for Powerline.ttf"

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "${zsh_rc_snippet}" "zsh"
fi

vim_rc_snippet=$(cat << 'EOF'
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=/usr/local/share/.vim/bundle/Vundle.vim
call vundle#begin('/usr/local/share/.vim/bundle')
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
  colorscheme default
  set background=dark
endtry
EOF
)

if [[ ! -d "$VUNDLE_DIR" ]]; then
  # Create vundle group
  if ! cat /etc/group | grep -e "^vundle:" > /dev/null 2>&1; then
      groupadd -r vundle
  fi
  usermod -a -G vundle ${USERNAME}

  git clone https://github.com/VundleVim/Vundle.vim.git ${VUNDLE_DIR}
  chown -R "root:vundle" "${VUNDLE_DIR}"
  chmod -R g+rws "${VUNDLE_DIR}"
  ln -s ${VUNDLE_DIR} /etc/skel/.vim
fi

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "${vim_rc_snippet}" "vim"
fi

if [ "${SET_THEME}" = "true" ]; then
  sed -i '/^antigen theme/s/.*/antigen theme agnoster/' /etc/zsh/zshrc
  sed -i '0,/^colorscheme/s//colorscheme gotham256/' /etc/vim/vimrc # replace the first occurrence 
  command -v code >/dev/null 2>&1 && code --install-extension alireza94.theme-gotham || echo "vscode not found. Please install vscode to use this script."
fi

#vim +silent! +PluginInstall +qall