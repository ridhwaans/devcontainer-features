#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source ./helpers.sh

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
RUBY_VERSION="${VERSION:-"latest"}" # 'system' or 'os-provided' checks the base image first, else installs 'latest'
RBENV_DIR="${RBENVINSTALLPATH:-"/usr/local/rbenv"}"

# Comma-separated list of ruby versions to be installed
# alongside RUBY_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${ADDITIONALVERSIONS:-""}"

# Determine the appropriate non-root user
USERNAME=$(get_non_root_user $USERNAME)

# Create rbenv group to the user's UID or GID to change while still allowing access to rbenv
if ! cat /etc/group | grep -e "^rbenv:" > /dev/null 2>&1; then
    groupadd -r rbenv
fi
usermod -a -G rbenv ${USERNAME}

# Adjust ruby version if required
if [ "${RUBY_VERSION}" = "none" ]; then
    RUBY_VERSION=
elif [ "${RUBY_VERSION}" = "latest" ]; then
    RUBY_VERSION="3.2.2"
fi

rbenv_rc_snippet=$(cat << 'EOF'

export RBENV_ROOT="/usr/local/rbenv"

[[ -d $RBENV_ROOT/bin ]] && export PATH="$RBENV_ROOT/bin:$PATH"

eval "$(rbenv init -)"
EOF
)

umask 0002
if [ ! -d "${RBENV_DIR}" ]; then
  git clone https://github.com/rbenv/rbenv.git ${RBENV_DIR}
  chown "${USERNAME}:rbenv" ${RBENV_DIR}
  chmod g+rws "${RBENV_DIR}" 

  git clone https://github.com/rbenv/ruby-build.git ${RBENV_DIR}/plugins/ruby-build
  git clone https://github.com/jf/rbenv-gemset.git ${RBENV_DIR}/plugins/rbenv-gemset

  updaterc "${rbenv_rc_snippet}"
else
    echo "rbenv already installed."
    
    # install prereqs: https://stackoverflow.com/a/9510209/3577482, https://github.com/rbenv/ruby-build/discussions/2118
    apt install -y --no-install-recommends libtool libyaml-dev
    
    if [ "${RUBY_VERSION}" != "" ]; then
        su ${USERNAME} -c "source /etc/zsh/zshrc && rbenv install ${RUBY_VERSION}"
    fi
fi

# Additional ruby versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            su ${USERNAME} -c "rbenv install ${version}"
        done
    IFS=$OLDIFS
fi 