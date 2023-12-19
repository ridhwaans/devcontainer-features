#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source $(dirname $0)/helpers.sh

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
UPDATE_RC="${UPDATE_RC:-"true"}"
RUBY_VERSION="${VERSION:-"latest"}" # 'system' or 'os-provided' checks the base image first, else installs 'latest'
RBENV_DIR="${RBENVINSTALLPATH:-"/usr/local/rbenv"}"

# Comma-separated list of ruby versions to be installed
# alongside RUBY_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${ADDITIONALVERSIONS:-""}"

# Determine the appropriate non-root user
USERNAME=$(get_non_root_user $USERNAME)

# Ensure apt is in non-interactive to avoid prompts
export DEBIAN_FRONTEND=noninteractive

# General requirements 
# https://stackoverflow.com/a/9510209/3577482, https://github.com/rbenv/ruby-build/discussions/2118
apt install -y --no-install-recommends ca-certificates software-properties-common build-essential gnupg2 libreadline-dev \
                                    procps dirmngr gawk autoconf automake bison libffi-dev libgdbm-dev libncurses5-dev \
                                    libsqlite3-dev libtool libyaml-dev pkg-config sqlite3 zlib1g-dev libgmp-dev libssl-dev

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
  chown -R "root:rbenv" ${RBENV_DIR}
  chmod -R g+rws "${RBENV_DIR}" 

  git clone https://github.com/rbenv/ruby-build.git ${RBENV_DIR}/plugins/ruby-build
  git clone https://github.com/jf/rbenv-gemset.git ${RBENV_DIR}/plugins/ruby-gemset
else
    echo "rbenv already installed."
fi

if [ "${UPDATE_RC}" = "true" ]; then
    updaterc "${rbenv_rc_snippet}"
fi

if [ "${RUBY_VERSION}" != "" ]; then
    # Find version using soft match
    find_version_from_git_tags RUBY_VERSION "https://github.com/ruby/ruby" "tags/v" "_"
    su ${USERNAME} -c "export RBENV_ROOT=${RBENV_DIR}; export PATH=$RBENV_DIR/bin:\$PATH; rbenv install ${RUBY_VERSION}"
fi

# Additional ruby versions to be installed but not be set as default.
if [ ! -z "${ADDITIONAL_VERSIONS}" ]; then
    OLDIFS=$IFS
    IFS=","
        read -a additional_versions <<< "$ADDITIONAL_VERSIONS"
        for version in "${additional_versions[@]}"; do
            su ${USERNAME} -c "export PATH=$RBENV_DIR/bin:\$PATH; rbenv install ${version}"
        done
    IFS=$OLDIFS
fi

echo "Done!"