#!/bin/zsh

#set -e

# Optional: Import test library
source dev-container-features-test-lib

source ~/.zshrc

# Check language managers
check "check for nvm" nvm --version
check "check for sdkman" sdk version
check "check for rbenv" rbenv --version
check "check for pyenv" pyenv --version

# Definition specific tests
check "check for node" node --version
check "check for java" java --version
check "check for ruby" ruby --version
check "check for python" python --version
check "check for go" go version

# Report result
reportResults
