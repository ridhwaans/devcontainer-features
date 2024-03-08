#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
FIRST_USER=$(id -nu 1000)
check "first user should be vscode" echo $FIRST_USER | grep "vscode"
check "user timezone should be UTC" echo $(date +%Z) | grep "UTC"
check "user lang should be UTF-8" echo $LANG | grep "en_US.UTF-8"
check "user shell should be zsh" sudo grep "^$FIRST_USER:" /etc/passwd | cut -d: -f7 | grep "zsh"

# Report result
reportResults
