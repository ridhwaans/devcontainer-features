#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Mac OS packages
install_mac_packages() {
  if ! command -v xcode-select &>/dev/null; then
    echo "Installing Command Line Tools..."
    xcode-select --install && sudo xcodebuild -license accept
  fi

	if ! command -v brew &> /dev/null; then
		echo "Installing Homebrew..."
		yes '' | sudo -u $USERNAME bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

  # Make sure we’re using the latest Homebrew
  run_brew_command_as_target_user update

  # Upgrade any already-installed formulae
  run_brew_command_as_target_user upgrade

  packages=(
      bash
      dockutil
      fontconfig
      fzf
      git
      grep
      jq
      neofetch
      tig
      tree
  )
  run_brew_command_as_target_user install "${packages[@]}"

  apps=(
      beekeeper-studio
      docker
      discord
      dropbox
      figma
      iterm2@nightly
      kap
      mounty
      notion
      postman
      steam
      visual-studio-code
  )

  if [ ! -d "/Applications/Google Chrome.app" ]; then
      apps+=(google-chrome)
  fi

  if [ ! -d "/Applications/Slack.app" ]; then
      apps+=(slack)
  fi

  if [ ! -d "/Applications/zoom.us.app" ]; then
      apps+=(zoom)
  fi

  run_brew_command_as_target_user install --cask "${apps[@]}"

  # Remove outdated versions from the cellar
  run_brew_command_as_target_user cleanup

	# Set Dock items
	OLDIFS=$IFS
	IFS=''

	apps=(
		'Google Chrome'
		'Visual Studio Code'
		iTerm
		'Beekeeper Studio'
		Postman
		Notion
		Slack
		Figma
		zoom.us
		Docker
		'System Settings'
	)

	dockutil --no-restart --remove all $HOME
	for app in "${apps[@]}"
	do
		echo "Keeping $app in Dock"
		dockutil --no-restart --add /Applications/$app.app $HOME
	done
	killall Dock

	# restore $IFS
	IFS=$OLDIFS
}

# Debian / Ubuntu packages
install_debian_packages() {
  # Ensure apt is in non-interactive to avoid prompts
  export DEBIAN_FRONTEND=noninteractive
  packages=(
    acl
    ca-certificates
    curl
    fontconfig
    fzf
    git
    jq
    locales
    neofetch
    sudo
    tig
    tree
    tzdata
    unzip
    vim
    wget
    zip
    zsh
  )

  # Install the list of packages
  apt update -y
  apt install -y --no-install-recommends "${packages[@]}"

  # Get to latest versions of all packages
  apt upgrade -y --no-install-recommends
  apt autoremove -y

  # Fix for https://github.com/ohmyzsh/ohmyzsh/issues/4786
  if ! grep -o -E '^\s*en_US.UTF-8\s+UTF-8' /etc/locale.gen > /dev/null; then
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
  fi
}

if [ "$ADJUSTED_ID" = "mac" ]; then
  dseditgroup -o edit -a $USERNAME -t user wheel
else
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
fi

# Add sudo support for non-root user
if [ "${USERNAME}" != "root" ]; then
  # Ensure /etc/sudoers.d exists
  [ -d /etc/sudoers.d ] || mkdir -p /etc/sudoers.d
  # Add the user to sudoers with no password requirement
  echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
  chmod 0440 /etc/sudoers.d/$USERNAME
fi

# Set default shell & verify
chsh -s /bin/zsh ${USERNAME}
if [ "$ADJUSTED_ID" = "mac" ]; then
  dscl . -read /Users/${USERNAME} UserShell
else
  getent passwd $USERNAME | awk -F: '{ print $7 }'
fi

echo "debugging username, uid, gid, shell"
cat /etc/passwd

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
    "mac")
        install_mac_packages
        ;;
esac

echo "Installing system-wide powerline font for shell prompt..."
if [ "$ADJUSTED_ID" = "mac" ]; then
  curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o /Library/Fonts/"Roboto Mono for Powerline.ttf"
  ls /Library/Fonts | grep "Roboto Mono for Powerline.ttf"
else
  curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o /usr/share/fonts/"Roboto Mono for Powerline.ttf"
  fc-cache -f -v
  fc-list | grep "Roboto Mono for Powerline.ttf"
fi

echo "Installing system-wide plugin manager for shell..."
[ ! -d ${ZSHPLUG_PATH} ] && git clone https://github.com/zplug/zplug ${ZSHPLUG_PATH}
if [ "$ADJUSTED_ID" != "mac" ]; then
  # Create group
  if ! cat /etc/group | grep -e "^zplug:" > /dev/null 2>&1; then
      groupadd -r zplug
  fi
  usermod -a -G zplug ${USERNAME}
  mkdir -p $ZSHPLUG_PATH/{cache,log,repos}

  chown -R "root:zplug" $(dirname $ZSHPLUG_PATH)
  chmod -R 775 $(dirname $ZSHPLUG_PATH)
fi

echo "Installing system-wide plugin manager for vim..."
curl -fLo "${VIMPLUG_PATH}/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
if [ "$ADJUSTED_ID" != "mac" ]; then
  # Create group
  if ! cat /etc/group | grep -e "^vimplug:" > /dev/null 2>&1; then
      groupadd -r vimplug
  fi
  usermod -a -G vimplug ${USERNAME}
  chown -R "root:vimplug" "$(dirname $VIMPLUG_PATH)"
  chmod -R 775 "$(dirname $VIMPLUG_PATH)"
fi

zsh_rc_snippet=$(cat <<EOF
export LANG=en_US.UTF-8
export ZPLUG_HOME="~/.zsh/bundle"
export ZSHPLUG_PATH="$ZSHPLUG_PATH"

source \$ZSHPLUG_PATH/init.zsh
fpath+=("\$ZSHPLUG_PATH/repos")

zplug "agnoster/3712874", from:gist, as:theme, use:agnoster.zsh-theme

if ! zplug check --verbose; then
  echo; zplug install
fi

zplug load --verbose
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "zsh" "${zsh_rc_snippet}"
fi

brew_rc_snippet=$(cat <<EOF
if [ \$(uname) = Darwin ]; then
  eval \$(/opt/homebrew/bin/brew shellenv)
fi
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "bash" "${brew_rc_snippet}"
  updaterc "zsh" "${brew_rc_snippet}"
fi

vim_rc_snippet=$(cat <<EOF
let g:vim_plug_home="$VIMPLUG_PATH"

execute 'source ' . g:vim_plug_home . '/autoload/plug.vim'
call plug#begin(g:vim_plug_home . '/plugged')
call plug#end()
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "vim" "${vim_rc_snippet}"
  sudo -u $USERNAME vim +silent! +PlugInstall +PlugClean +qall
fi

echo "Done!"
