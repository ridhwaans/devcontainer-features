#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "should be logged in as the created user" echo $(whoami) | grep "vscode"
check "user should have a uid of 1000" echo $(id -nu 1000) | grep "vscode"
check "user default shell should be zsh" bash -c "getent passwd $(whoami) | awk -F: '{ print $7 }' | grep '/bin/zsh'"
check "user default timezone should be UTC" echo $(date +%Z) | grep "UTC"

check "zsh version" zsh --version
check "vim version" vim --version | head -n 1
# Check plugin managers
VIMPLUG_PATH="/usr/local/share/vim/bundle"
check "check for vim-plug" ls -1 $VIMPLUG_PATH/autoload/plug.vim | wc -l

# Report result
reportResults
