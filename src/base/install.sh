#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
SET_THEME="${SETTHEME:-"true"}"

scripts=(
  common-utils.sh
  java.sh
  python.sh
  ruby.sh
  node.sh
  go.sh
  aws.sh
)
script_dir="$(dirname "$0")/scripts"

for script in "${scripts[@]}"; do
    /bin/bash "$script_dir/$script" "$@"

    script_status=$?

    if [ $script_status -eq 0 ]; then
        echo "Script '$script' executed successfully."
    else
        echo "Error: Script '$script' failed to execute with status $script_status."
        exit 1
    fi
done

# Exit with the exit code of the last executed script
exit $?
