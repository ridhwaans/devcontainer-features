#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source $(dirname $0)/_helper.sh

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
UPDATE_RC="${UPDATERC:-"true"}"
GO_VERSION="${GOVERSION:-"latest"}" # 'system' or 'os-provided' checks the base image first, else installs 'latest'
GO_DIR="${GOINSTALLPATH:-"/usr/local/go"}"
GO_PATH="${GOPATH:-"/go"}"

# Determine the appropriate non-root user
USERNAME=$(get_non_root_user $USERNAME)

if [ "$ADJUSTED_ID" = "mac" ]; then
    packages=(
      go
    )
    brew install "${packages[@]}"
else
  # Verify requested version is available, convert latest
  find_version_from_git_tags GO_VERSION "https://go.googlesource.com/go" "tags/go" "." "true"

  # Create golang group to the user's UID or GID to change while still allowing access to nvm
  if ! cat /etc/group | grep -e "^golang:" > /dev/null 2>&1; then
      groupadd -r golang
  fi
  usermod -a -G golang ${USERNAME}
  mkdir -p "${GO_DIR}" "${GO_PATH}"

  if [[ "${GO_VERSION}" != "none" ]] && [[ "$(go version 2>/dev/null)" != *"${GO_VERSION}"* ]]; then
    echo "Downloading Go ${GO_VERSION}..."
      set +e
      curl -fsSL -o /tmp/go.tar.gz "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
      tar -xzf /tmp/go.tar.gz -C "${GO_DIR}" --strip-components=1
      rm -rf /tmp/go.tar.gz
  else
      echo "(!) Go is already installed with version ${GO_VERSION}. Skipping."
  fi

  chown -R "root:golang" "${GO_DIR}" "${GO_PATH}"
  chmod -R g+rws "${GO_DIR}" "${GO_PATH}"
fi

go_rc_snippet=$(cat << EOF
export PATH="$GO_DIR/bin:\$PATH"
export GOPATH="$GO_PATH"
EOF
)

if [ "${UPDATE_RC}" = "true" ]; then
  updaterc "zsh" "${go_rc_snippet}"
  updaterc "bash" "${go_rc_snippet}"
fi

echo "Done!"