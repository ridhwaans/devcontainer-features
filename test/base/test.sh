#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "system info" screenfetch

# Report result
reportResults