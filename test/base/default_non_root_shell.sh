#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "default non-root shell is zsh" sudo -u vscode bash -c "getent passwd $(whoami) | awk -F: '{ print $7 }' | grep '/bin/zsh'"

# Report result
reportResults