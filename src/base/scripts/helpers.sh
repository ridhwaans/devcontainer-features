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
  local rc_file="${1:-"~/.zshrc"}"

  if [ "${UPDATE_RC}" = "true" ]; then
      echo "Updating ${rc_file}..."
      if [ -f "${rc_file}" ] && [[ "$(cat ${rc_file})" != *"$1"* ]]; then
          echo -e "$1" >> ${rc_file}
      fi
  fi
}

version_manager_exists(){
  local version_manager=$1

  # Just install language version if version manager already installed
  if version_manager --version > /dev/null; then
      echo "Version Manager already exists."
      return 0  # Return true (0)
  else
      return 1  # Return false (non-zero)
  fi
}

plugin_manager_exists(){
  local install_dir=$1

  # Just install language version if version manager already installed
  if [ ! -d "${install_dir}" ]; then
    echo "Version Manager already exists."
    return 0  # Return true (0)
  else
    return 1  # Return false (non-zero)
  fi
}
