#!/bin/zsh

#set -e

# Optional: Import test library
source dev-container-features-test-lib

CREATED_USER=$(id -nu 1000)
ZSHPLUG_PATH="/usr/local/share/zsh/bundle"
VIMPLUG_PATH="/usr/local/share/vim/bundle"

check "created user should be vscode" echo $CREATED_USER | grep "vscode"
check "user timezone should be UTC" echo $(date +%Z) | grep "UTC"
check "user lang should be UTF-8" echo $LANG | grep "en_US.UTF-8"
check "user shell should be zsh" sudo grep "^$CREATED_USER:" /etc/passwd | cut -d: -f7 | grep "zsh"

# Check plugin managers
check "should be logged in as the provided user" echo $LOGNAME | grep "vscode"
source ~/.zshrc
check "check for zplug" zplug --version
check "check for vim-plug" ls -1 $VIMPLUG_PATH/autoload/plug.vim | wc -l

# Check language managers
check "check for nvm" nvm --version
check "check for sdkman" sdk version
check "check for rbenv" rbenv --version
check "check for pyenv" pyenv --version

# Report result
reportResults
