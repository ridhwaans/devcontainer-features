#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "check for node" node --version
check "check for java" java --version
check "check for ruby" ruby --version
check "check for python" python --version
check "check for go" go version

# Report result
reportResults
