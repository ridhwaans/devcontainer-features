#!/usr/bin/env zsh

set -e

# Optional: Import test library
source dev-container-features-test-lib

source ~/.zshrc

# Definition specific tests
check "check for aws" aws --version
check "check for sam" sam --version
check "check for cfn-lint" cfn-lint --version
check "check for terraform" terraform -version
check "check for gh" gh --version
check "check for exercism" exercism version

# Report result
reportResults
