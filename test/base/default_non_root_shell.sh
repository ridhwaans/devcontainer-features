#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

current_user=$(whoami)
echo "Hello, $current_user!"
echo "Current shell: $SHELL"

# Definition specific tests
check "default non-root shell is zsh" sudo grep "^vscode:" /etc/passwd | cut -d: -f7

# Report result
reportResults