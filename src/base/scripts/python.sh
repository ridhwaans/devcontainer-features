#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source $(dirname $0)/helpers.sh

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
UPDATE_RC="${UPDATE_RC:-"true"}"
PYTHON_VERSION="${VERSION:-"latest"}" # 'system' or 'os-provided' checks the base image first, else installs 'latest'
PYENV_DIR="${PYENVINSTALLPATH:-"/usr/local/pyenv"}"

# Comma-separated list of python versions to be installed
# alongside PYTHON_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${ADDITIONALVERSIONS:-""}"

# Determine the appropriate non-root user
USERNAME=$(get_non_root_user $USERNAME)

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# General requirements 
# https://stackoverflow.com/a/71347968/3577482, liblzma-dev
apt install -y --no-install-recommends libssl-dev libffi-dev libncurses5-dev zlib1g zlib1g-dev libreadline-dev libbz2-dev libsqlite3-dev make gcc liblzma-dev

# Create pyenv group to the user's UID or GID to change while still allowing access to pyenv
if ! cat /etc/group | grep -e "^pyenv:" > /dev/null 2>&1; then
    groupadd -r pyenv
fi
usermod -a -G pyenv ${USERNAME}

# Adjust python version if required
if [ "${PYTHON_VERSION}" = "none" ]; then
    PYTHON_VERSION=
elif [ "${PYTHON_VERSION}" = "latest" ]; then
    PYTHON_VERSION="3.12:latest"
fi

pyenv_rc_snippet=$(cat << 'EOF'

export PYENV_ROOT="/usr/local/pyenv"

[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

eval "$(pyenv virtualenv-init -)"
EOF
)

umask 0002
if [ ! -d "${PYENV_DIR}" ]; then
  git clone https://github.com/pyenv/pyenv.git ${PYENV_DIR}
  chown "${USERNAME}:pyenv" ${PYENV_DIR}
  chmod g+rws "${PYENV_DIR}" 

  git clone https://github.com/pyenv/pyenv-virtualenv.git ${PYENV_DIR}/plugins/pyenv-virtualenv
else
    echo "pyenv already installed."

    if [ "${PYTHON_VERSION}" != "" ]; then
        su ${USERNAME} -c "source /etc/zsh/zshrc && pyenv install ${PYTHON_VERSION}"
    fi
fi

if [ "${UPDATE_RC}" = "true" ]; then
    updaterc "${pyenv_rc_snippet}"
fi

# Additional python versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            su ${USERNAME} -c "pyenv install ${version}"
        done
    IFS=$OLDIFS
fi
