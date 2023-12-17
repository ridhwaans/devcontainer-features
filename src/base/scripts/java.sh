#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source ./helpers.sh

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
JAVA_VERSION="${VERSION:-"latest"}" # 'system' or 'os-provided' checks the base image first, else installs 'latest'
SDKMAN_DIR="${SDKMANINSTALLPATH:-"/usr/local/sdkman"}"

# Comma-separated list of java versions to be installed
# alongside JAVA_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${ADDITIONALVERSIONS:-""}"

# Determine the appropriate non-root user
USERNAME=$(get_non_root_user $USERNAME)

# Create sdkman group to the user's UID or GID to change while still allowing access to sdkman
if ! cat /etc/group | grep -e "^sdkman:" > /dev/null 2>&1; then
    groupadd -r sdkman
fi
usermod -a -G sdkman ${USERNAME}

# Adjust java version if required
if [ "${JAVA_VERSION}" = "none" ]; then
    JAVA_VERSION=
elif [ "${JAVA_VERSION}" = "latest" ]; then
    JAVA_VERSION="3.2.2"
fi

sdkman_rc_snippet=$(cat << 'EOF'

export SDKMAN_DIR="/usr/local/sdkman"

[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
EOF
)

umask 0002
if [ ! -d "${SDKMAN_DIR}" ]; then
  curl -s "https://get.sdkman.io" | bash
  chown "${USERNAME}:sdkman" ${SDKMAN_DIR}
  chmod g+rws "${SDKMAN_DIR}" 

  updaterc "${sdkman_rc_snippet}"
else
    echo "sdkman already installed."
    
    if [ "${JAVA_VERSION}" != "" ]; then
        su ${USERNAME} -c "source /usr/local/sdkman/bin/sdkman-init.sh && sdk install ${JAVA_VERSION}"
    fi
fi

# Additional Java versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            su ${USERNAME} -c "sdk install ${version}"
        done
    IFS=$OLDIFS
fi