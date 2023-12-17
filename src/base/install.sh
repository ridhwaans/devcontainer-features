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
  node.sh
  java.sh
  ruby.sh
  python.sh
  go.sh
  tools.sh
)

for script in "${scripts[@]}"; do
  exec /bin/bash "$(dirname "$0")/scripts/$script" "$@"
done

# Exit with the exit code of the last executed script
exit $?
