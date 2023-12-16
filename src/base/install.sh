#!/bin/sh

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

USERNAME="${USERNAME:-"automatic"}"
USER_UID="${USERUID:-"automatic"}"
USER_GID="${USERGID:-"automatic"}"
SET_THEME="${SETTHEME:-"true"}"

exec /bin/bash "$(dirname $0)/common-utils.sh" "$@"
#exec /bin/bash "$(dirname $0)/main.sh" "$@"
exit $?
