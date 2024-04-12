#!/usr/bin/env zsh

#set -e

# Optional: Import test library
source dev-container-features-test-lib

check "user lang should be UTF-8" echo $LANG | grep "en_US.UTF-8"
check "check for zplug" zplug --version
