#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

current_user=$(whoami)
echo "Hello, $current_user!"
echo "Current shell: $SHELL"

# Definition specific tests
check "non-root user default shell is zsh" sudo grep "^$current_user:" /etc/passwd | cut -d: -f7

# Report result
reportResults