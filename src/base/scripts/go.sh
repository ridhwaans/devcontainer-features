#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source $(dirname $0)/helpers.sh

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"
GO_VERSION="${VERSION:-"latest"}" # 'system' or 'os-provided' checks the base image first, else installs 'latest'

# Verify requested version is available, convert latest
find_version_from_git_tags GO_VERSION 'https://github.com/golang/go'

# Comma-separated list of python versions to be installed
# alongside GO_VERSION, but not set as default.
ADDITIONAL_VERSIONS="${ADDITIONALVERSIONS:-""}"

# Determine the appropriate non-root user
USERNAME=$(get_non_root_user $USERNAME)

if [[ "$(go version)" = *"${GO_VERSION}"* ]]; then
  echo "(!) Go is already installed with version ${GO_VERSION}. Skipping..."
elif [ "${GO_VERSION}" != "none" ]; then
  echo "Installing specified Go version."
  find_version_from_git_tags GO_VERSION "https://go.googlesource.com/go" "tags/go" "." "true"
  su ${USERNAME} -c "apt install -y --no-install-recommends ${GO_VERSION}"
fi