#!/usr/bin/env bash

updaterc() {
  declare -A rc_paths=(
    [vim]="$(eval echo "~$USERNAME")/.vimrc"
    [bash]="$(eval echo "~$USERNAME")/.bashrc"
    [zsh]="$(eval echo "~$USERNAME")/.zshrc"
  )
  local rc_key=$1
  local rc_content=$2

  rc_path="${rc_paths[$rc_key]}"
  rc_dir=$(dirname "$rc_path")
  [ ! -d "$rc_dir" ] && mkdir -p "$rc_dir"
  [ ! -f "$rc_path" ] && touch "$rc_path"

  if [[ "$(cat $rc_path)" = *"$rc_content"* ]]; then
    echo "Content already exists in $rc_path"
  else
    echo "Updating $rc_path..."
    echo -e "$rc_content" >> "$rc_path"
  fi
}

run_brew_command_as_target_user() {
    sudo -u $USERNAME brew "$@"
}

conditional_grep() {
    # use gnu grep for pcre, not bsd grep
    if [ "$ADJUSTED_ID" = "mac" ]; then
        ggrep "$@"
    else
        grep "$@"
    fi
}

# Figure out correct version of a three part version number is not passed
# Requires /bin/bash to run; ./ and /bin/zsh do not support indirect variable reference and extended pattern substitution syntax (//).
find_version_from_git_tags() {
    local variable_name=$1
    local requested_version=${!variable_name}
    if [ "${requested_version}" = "none" ]; then return; fi
    local repository=$2
    local prefix=${3:-"tags/v"}
    local separator=${4:-"."}
    local last_part_optional=${5:-"false"}
    if [ "$(echo "${requested_version}" | grep -o "." | wc -l)" != "2" ]; then
        local escaped_separator=${separator//./\\.}
        local last_part
        if [ "${last_part_optional}" = "true" ]; then
            last_part="(${escaped_separator}[0-9]+)?"
        else
            last_part="${escaped_separator}[0-9]+"
        fi
        local regex="${prefix}\\K[0-9]+${escaped_separator}[0-9]+${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | conditional_grep -oP "${regex}" | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            declare -g ${variable_name}="$(echo "${version_list}" | head -n 1)"
        else
            set +e
            declare -g ${variable_name}="$(echo "${version_list}" | conditional_grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | conditional_grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

export -f updaterc
export -f find_version_from_git_tags
export -f run_brew_command_as_target_user
export -f conditional_grep
