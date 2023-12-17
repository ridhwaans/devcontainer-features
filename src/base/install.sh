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
  aws.sh
)
script_dir="$(dirname "$0")/scripts"

# Run the first script in a Bash shell
/bin/bash "$script_dir/${scripts[0]}" "$@"

# Now, the remaining scripts will run in the new Zsh shell
for script in "${scripts[@]:1}"; do
    # Run the script
    /bin/zsh "$script_dir/$script" "$@"

    # Check the exit status of the last command (the script)
    script_status=$?

    if [ $script_status -eq 0 ]; then
        echo "Script '$script' executed successfully."
    else
        echo "Error: Script '$script' failed to execute with status $script_status."
        exit 1  # Exit the entire script if any script fails
    fi
done

# Exit with the exit code of the last executed script
exit $?
