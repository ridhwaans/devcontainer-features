#!/usr/bin/env bash

set -e

SCRIPT_HOME="$(dirname $0)"

echo "For user ${USERNAME}"

if [ $(uname) = Darwin ]; then
	echo "(mac)"

  VSCODE_SETTINGS_DIR=$HOME/Library/Application\ Support/Code/User

elif [ $(uname) = Linux ]; then
	if [ -n "$WSL_DISTRO_NAME" ]; then
		echo "(wsl)"

    WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
    VSCODE_SETTINGS_DIR=$WINDOWS_HOME/AppData/Roaming/Code/User

    jq --argjson terminal "$(cat "$SCRIPT_HOME/themes/$THEME/terminal.json")" \
   '.schemes = [ $terminal ]' \
   "$WINDOWS_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json" \
   > temp.json && mv temp.json "$WINDOWS_HOME/AppData/Local/Packages/Microsoft.WindowsTerminal*/LocalState/settings.json"

  elif [ -n "$CODESPACES" ]; then
		echo "(github codespaces)"

	else
		echo "(native linux)"

    VSCODE_SETTINGS_DIR=$HOME/.config/Code/User
  fi
fi


if command -v code &>/dev/null; then

  source $SCRIPT_HOME/themes/$THEME/vscode.sh
  code --install-extension $VSCODE_ICON_EXTENSION >/dev/null
  code --install-extension $VSCODE_COLOR_EXTENSION >/dev/null
  sed -i "s/\"workbench.iconTheme\": \".*\"/\"workbench.iconTheme\": \"$VSCODE_ICON_THEME\"/g" "$VSCODE_SETTINGS_DIR"/settings.json
  sed -i "s/\"workbench.colorTheme\": \".*\"/\"workbench.colorTheme\": \"$VSCODE_COLOR_THEME\"/g" "$VSCODE_SETTINGS_DIR"/settings.json
fi

# Shell

# cp $SCRIPT_HOME/themes/$THEME/shell.sh $HOME/.local/share/themes/$THEME.sh

# zsh_rc_snippet=$(cat <<EOF
# SHELL_THEME="\$HOME/.local/share/themes/$THEME.sh"
# [[ -s \$SHELL_THEME ]] && source \$SHELL_THEME
# EOF
# )

# updaterc "zsh" "${zsh_rc_snippet}"
