#!/usr/bin/env bash

updaterc() {
  rc_paths=("vim" "$(eval echo "~$USERNAME")/.vimrc"
          "bash" "$(eval echo "~$USERNAME")/.profile"
          "zsh" "$(eval echo "~$USERNAME")/.zshrc")

  get_value_by_key() {
    local key="$1"
    local index
    for ((index = 0; index < ${#rc_paths[@]}; index+=2)); do
        if [[ "${rc_paths[index]}" == "$key" ]]; then
            echo "${rc_paths[index+1]}"
            return 0
        fi
    done
    return 1
  }

  local rc_key=$1
  local rc_content=$2

  rc_path=$(get_value_by_key "$rc_key")
  rc_dir=$(dirname "$rc_path")
  [ ! -d "$rc_dir" ] && mkdir -p "$rc_dir"
  [ ! -f "$rc_path" ] && touch "$rc_path"
  if [ "$ADJUSTED_ID" != "mac" ]; then
     [ "$(stat -c '%U:%G' "$rc_path")" != "$USERNAME:$USERNAME" ] && chown $USERNAME:$USERNAME $rc_path
  else
     [ "$(stat -f '%Su:%Sg' "$rc_path")" != "$USERNAME:staff" ] && chown $USERNAME:staff $rc_path
  fi
  if [[ "$(cat $rc_path)" = *"$rc_content"* ]]; then
    echo "Content already exists in $rc_path"
  else
    echo "Updating $rc_path..."
    echo -e "$rc_content" >> "$rc_path"
  fi
}

run_brew_command_as_target_user() {
    # workaround for issue running brew as root
    eval "$(/opt/homebrew/bin/brew shellenv)" && sudo -u $USERNAME brew "$@"
}

conditional_grep() {
    # use gnu grep for pcre, else use bsd grep
    if [ "$ADJUSTED_ID" = "mac" ]; then
        ggrep "$@"
    else
        grep "$@"
    fi
}

# Figure out correct version of a three part version number is not passed
# Requires Bash. Zsh does not support indirect variable reference and extended pattern substitution syntax (//).
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
            last_part="(${escaped_separator}[0-9a-zA-Z]+)?"
        else
            last_part="${escaped_separator}[0-9a-zA-Z]+"
        fi
        local regex="${prefix}\\K[0-9]+(${escaped_separator}[0-9]+)*${last_part}$"
        local version_list="$(git ls-remote --tags ${repository} | conditional_grep -oP "${regex}" | grep -v '\^{}' | tr -d ' ' | tr "${separator}" "." | sort -rV)"
        echo $version_list
        if [ "${requested_version}" = "latest" ] || [ "${requested_version}" = "current" ] || [ "${requested_version}" = "lts" ]; then
            local latest_version="$(echo "${version_list}" | head -n 1)"
            eval "${variable_name}='${latest_version}'"
        else
            set +e
            local matching_version="$(echo "${version_list}" | grep -E -m 1 "^${requested_version//./\\.}([\\.\\s]|$)")"
            eval "${variable_name}='${matching_version}'"
            set -e
        fi
    fi
    if [ -z "${!variable_name}" ] || ! echo "${version_list}" | grep "^${!variable_name//./\\.}$" > /dev/null 2>&1; then
        echo -e "Invalid ${variable_name} value: ${requested_version}\nValid values:\n${version_list}" >&2
        exit 1
    fi
    echo "${variable_name}=${!variable_name}"
}

export -f updaterc
export -f find_version_from_git_tags
export -f run_brew_command_as_target_user
export -f conditional_grep
