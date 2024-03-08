#!/bin/zsh

#set -e

# Optional: Import test library
source dev-container-features-test-lib

source ~/.zshrc
check "should be logged in as the provided user" echo $LOGNAME | grep "vscode"

# Check plugin managers
check "check for zplug" zplug --version
VIMPLUG_PATH="/usr/local/share/vim/bundle"
check "check for vim-plug" ls -1 $VIMPLUG_PATH/autoload/plug.vim | wc -l

# Check language managers
check "check for nvm" nvm --version
check "check for sdkman" sdk version
check "check for rbenv" rbenv --version
check "check for pyenv" pyenv --version

# Report result
reportResults
