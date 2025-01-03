echo "Installing system-wide powerline font for shell prompt..."
if [ "$ADJUSTED_ID" = "mac" ]; then
  curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o /Library/Fonts/"Roboto Mono for Powerline.ttf"
  ls /Library/Fonts | grep "Roboto Mono for Powerline.ttf"
else
  curl -L https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf --create-dirs -o /usr/share/fonts/"Roboto Mono for Powerline.ttf"
  fc-cache -f -v
  fc-list | grep "Roboto Mono for Powerline.ttf"
fi

#!/usr/bin/env bash

set -e

SCRIPT_HOME="$(dirname $0)"

echo "For user ${USERNAME}"

set_font() {
	local file=$1
	local url=$2

	if ! $(fc-list | grep -i "$font_name" >/dev/null); then
    if [ "$ADJUSTED_ID" = "mac" ]; then
      echo "(mac)"

      VSCODE_SETTINGS_DIR=$HOME/Library/Application\ Support/Code/User

      curl -L $url --create-dirs -o /Library/Fonts/"$file"
      ls /Library/Fonts | grep $file

    elif [ $(uname) = Linux ]; then
      if [ -n "$WSL_DISTRO_NAME" ]; then
        echo "(wsl)"

        WINDOWS_HOME=$(wslpath $(powershell.exe '$env:UserProfile') | sed -e 's/\r//g')
        VSCODE_SETTINGS_DIR=$WINDOWS_HOME/AppData/Roaming/Code/User

        curl -L $url --create-dirs -o /usr/share/fonts/"$file"
        fc-cache -f -v
        fc-list | grep $file

      elif [ -n "$CODESPACES" ]; then
		    echo "(github codespaces)"

      else
        echo "(native linux)"

        VSCODE_SETTINGS_DIR=$HOME/.config/Code/User
      fi
    fi
	fi

  if command -v code &>/dev/null; then
    # Extract the base name (without the extension)
    base_name="${file%.*}"
    sed -i "s/\"editor.fontFamily\": \".*\"/\"editor.fontFamily\": \"$base_name\"/g" "$VSCODE_SETTINGS_DIR"/settings.json
    sed -i "s/\"terminal.integrated.fontFamily\": \".*\"/\"terminal.integrated.fontFamily\": \"$base_name\"/g" "$VSCODE_SETTINGS_DIR"/settings.json
  fi
}

echo "Installing system-wide powerline font for shell prompt..."
set_font "Roboto Mono for Powerline.ttf" "https://github.com/powerline/fonts/raw/master/RobotoMono/Roboto%20Mono%20for%20Powerline.ttf"
