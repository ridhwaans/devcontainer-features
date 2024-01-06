#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

USERNAME="${USERNAME:-"automatic"}"
USERUID="${USERUID:-"automatic"}"
USERGID="${USERGID:-"automatic"}"
UPDATERC="${UPDATERC:-"true"}"
SETTHEME="${SETTHEME:-"true"}"
VUNDLEINSTALLPATH="${VUNDLEINSTALLPATH:-"/usr/local/share/.vim/bundle/Vundle.vim"}"
ANTIGENINSTALLPATH="${ANTIGENINSTALLPATH:-"/usr/local/share/.zsh/bundle"}"

JAVAVERSION="${JAVAVERSION:-"lts"}"
INSTALLGRADLE="${INSTALLGRADLE:-"false"}"
GRADLEVERSION="${GRADLEVERSION:-"latest"}"
INSTALLMAVEN="${INSTALLMAVEN:-"false"}"
MAVENVERSION="${MAVENVERSION:-"latest"}"
SDKMANINSTALLPATH="${SDKMANINSTALLPATH:-"/usr/local/sdkman"}"
JAVAADDITIONALVERSIONS="${JAVAADDITIONALVERSIONS:-""}"

PYTHONVERSION="${PYTHONVERSION:-"latest"}"
PYENVINSTALLPATH="${PYENVINSTALLPATH:-"/usr/local/pyenv"}"
PYTHONADDITIONALVERSIONS="${PYTHONADDITIONALVERSIONS:-""}"

RUBYVERSION="${RUBYVERSION:-"latest"}"
RBENVINSTALLPATH="${RBENVINSTALLPATH:-"/usr/local/rbenv"}"
RUBYADDITIONALVERSIONS="${RUBYADDITIONALVERSIONS:-""}"

NODEVERSION="${NODEVERSION:-"latest"}"
NVMINSTALLPATH="${NVMINSTALLPATH:-"/usr/local/nvm"}"
NODEADDITIONALVERSIONS="${NODEADDITIONALVERSIONS:-""}"

GOVERSION="${GOVERSION:-"latest"}"
GOINSTALLPATH="${GOINSTALLPATH:-"/usr/local/go"}"
GOPATH="${GOPATH:-"/go"}"

EXERCISMVERSION="${EXERCISMVERSION:-"latest"}"
TERRAFORMVERSION="${TERRAFORMVERSION:-"latest"}"

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

script_count=${#scripts[@]}
current_script=1

for script in "${scripts[@]}"; do
    /bin/bash "$script_dir/$script" "$@"

    script_status=$?

    if [ $script_status -eq 0 ]; then
        echo "($current_script/$script_count) Script '$script' executed successfully."
    else
        echo "Error: ($current_script/$script_count) Script '$script' failed to execute with status $script_status."
        exit 1
    fi

    ((current_script++))
done

# Exit with the exit code of the last executed script
exit $?
