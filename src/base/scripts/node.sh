#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source $(dirname $0)/helpers.sh

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
UPDATE_RC="${UPDATERC:-"true"}"
NODE_VERSION="${NODEVERSION:-"latest"}" # 'system' or 'os-provided' checks the base image first, else installs 'latest'
export NVM_DIR="${NVMINSTALLPATH:-"/usr/local/nvm"}"

# Comma-separated list of node versions to be installed
# alongside NODE_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${NODEADDITIONALVERSIONS:-""}"

# Determine the appropriate non-root user
USERNAME=$(get_non_root_user $USERNAME)

# Create nvm group to the user's UID or GID to change while still allowing access to nvm
if ! cat /etc/group | grep -e "^nvm:" > /dev/null 2>&1; then
    groupadd -r nvm
fi
usermod -a -G nvm ${USERNAME}

# Adjust node version if required
if [ "${NODE_VERSION}" = "none" ]; then
    NODE_VERSION=
elif [ "${NODE_VERSION}" = "lts" ]; then
    NODE_VERSION="lts/*"
elif [ "${NODE_VERSION}" = "latest" ]; then
    NODE_VERSION="node"
fi

nvm_rc_snippet=$(cat <<EOF
export NVM_DIR="\$([ -z "\${XDG_CONFIG_HOME-}" ] && printf %s "$NVM_DIR" || printf %s "\${XDG_CONFIG_HOME}/nvm")"

[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
EOF
)

umask 0002
if [ ! -d "${NVM_DIR}" ]; then
    git clone https://github.com/nvm-sh/nvm.git ${NVM_DIR}
    chown -R "root:nvm" "${NVM_DIR}"
    chmod -R g+rws "${NVM_DIR}"
    source ${NVM_DIR}/nvm.sh
else
    echo "nvm already installed."
fi

if [ "${UPDATE_RC}" = "true" ]; then
    updaterc "${nvm_rc_snippet}"
fi

if [ "${NODE_VERSION}" != "" ]; then
    su ${USERNAME} -c "umask 0002 && source ${NVM_DIR}/nvm.sh && nvm install '${NODE_VERSION}' && nvm alias default '${NODE_VERSION}'"
fi

# Additional node versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            su ${USERNAME} -c "umask 0002 && source ${NVM_DIR}/nvm.sh && nvm install ${version}"
        done

        if [ "${NODE_VERSION}" != "" ]; then
          su ${USERNAME} -c "umask 0002 && source ${NVM_DIR}/nvm.sh && nvm use default"
        fi
    IFS=$OLDIFS
fi

echo "Done!"