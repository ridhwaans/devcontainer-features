#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

# Mac OS packages
install_mac_packages() {
    packages=(
      tmux
    )
    run_brew_command_as_target_user install "${packages[@]}"
}

# Debian / Ubuntu packages
install_debian_packages(){
    # Ensure apt is in non-interactive to avoid prompts
    export DEBIAN_FRONTEND=noninteractive
    apt install -y --no-install-recommends libevent-dev ncurses-dev bison
}

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
    "mac")
        install_mac_packages
        ;;
esac

if [ "$ADJUSTED_ID" != "mac" ]; then
  # Verify requested version is available, convert latest
  find_version_from_git_tags TMUX_VERSION "https://github.com/tmux/tmux" "tags/"

  if [[ "${TMUX_VERSION}" != "none" ]] && [[ "$(tmux -V 2>/dev/null)" != *"${TMUX_VERSION}"* ]]; then
    echo "Downloading tmux ${TMUX_VERSION}..."
    set +e
    curl -sL https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz | tar -xzC /tmp 2>&1
    cd /tmp/tmux-${ADJUSTED_VERSION}
    ./configure
    make && make install
  else
      echo "(!) tmux is already installed with version ${TMUX_VERSION}. Skipping."
  fi
fi

echo "Done!"
