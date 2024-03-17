#!/bin/zsh

#set -e

# Optional: Import test library
source dev-container-features-test-lib

source ~/.zshrc
echo "shell is $(ps -p $$)"

ZSHPLUG_PATH="/usr/local/share/zsh/bundle"
VIMPLUG_PATH="/usr/local/share/vim/bundle"

check "should be logged in as the created user" echo $LOGNAME | grep "vscode"
check "user should have a uid of 1000" echo $(id -nu 1000) | grep "vscode"
check "user timezone should be UTC" echo $(date +%Z) | grep "UTC"
check "user lang should be UTF-8" echo $LANG | grep "en_US.UTF-8"
check "user shell should be zsh" sudo grep "^$LOGNAME:" /etc/passwd | cut -d: -f7 | grep "zsh"

# Check plugin managers
check "check for zplug" zplug --version
check "check for vim-plug" ls -1 $VIMPLUG_PATH/autoload/plug.vim | wc -l



# Report result
reportResults
