#!/bin/bash

which_env() {
  if [ $(uname) = Darwin ]; then
    return "(mac)"
  elif [ $(uname) = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      return "(wsl)"
    elif [ -n "$CODESPACES" ]; then
      return "(github codespaces)"
    else
		  return "(native linux)"
    fi
  fi
}

updaterc() {
  local rc_file="${2:-"/etc/zsh/zshrc"}"

  echo "Updating ${rc_file}..."
  if [ -f "${rc_file}" ] && [[ "$(cat ${rc_file})" != *"$1"* ]]; then
      echo -e "$1" >> ${rc_file} > /dev/null 2>&1
  fi
}

get_non_root_user() {
  local USERNAME

  if [ "${1}" = "auto" ] || [ "${1}" = "automatic" ]; then
    USERNAME=""
    FIRST_USER="$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)"
    if id -u ${FIRST_USER} > /dev/null 2>&1; then
      USERNAME=${FIRST_USER}
    fi
    [ "${USERNAME}" = "" ] && USERNAME="root"
  elif [ "${1}" = "none" ] || ! id -u "${1}" > /dev/null 2>&1; then
    USERNAME="root"
  else
    USERNAME="${1}"
  fi

  echo "${USERNAME}"
}