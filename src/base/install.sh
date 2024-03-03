#!/usr/bin/env bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

start_time=$(date +%s)

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

source $(dirname $0)/scripts/_config.sh
source $(dirname $0)/scripts/_helper.sh

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
echo -e "Install took $elapsed seconds"

exit $?
