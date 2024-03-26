#!/usr/bin/env zsh

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "system info" neofetch

# Report result
reportResults