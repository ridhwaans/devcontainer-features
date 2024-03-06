#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

start_time=$(date +%s)

source $(dirname $0)/scripts/_config.sh
source $(dirname $0)/scripts/_helper.sh

if [ $(uname) = Darwin ]; then
  export ADJUSTED_ID="mac"
elif [ $(uname) = Linux ]; then
  # Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
  . /etc/os-release

  # Get an adjusted ID independent of distro variants
  if [ "${ID}" = "debian" ] || [ "${ID_LIKE}" = "debian" ]; then
    export ADJUSTED_ID="debian"
  else
    echo "Linux distro ${ID} not supported."
    exit 1
  fi
fi

# If in automatic mode, determine if a user already exists, if not use vscode
if [ "${USERNAME}" = "auto" ] || [ "${USERNAME}" = "automatic" ]; then
  USERNAME=""
  if [ "$ADJUSTED_ID" = "mac" ]; then
    FIRST_USER=$(dscl . -list /Users UniqueID | awk -v val=501 '$2 == val {print $1}')
  else
    FIRST_USER="$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)"
  fi
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

scripts=(
  common-utils.sh
  java.sh
  python.sh
  ruby.sh
  node.sh
  go.sh
  tools.sh
)

script_dir="$(dirname "$0")/scripts"
script_count=${#scripts[@]}
current_script=1

for script in "${scripts[@]}"; do
    $(which bash) "$script_dir/$script" "$@"

    script_status=$?

    if [ $script_status -eq 0 ]; then
        echo "($current_script/$script_count) Script '$script' executed successfully."
    else
        echo "Error: ($current_script/$script_count) Script '$script' failed to execute with status $script_status."
        exit 1
    fi

    ((current_script++))
done

end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
echo -e "Install took $elapsed seconds."

exit $?
