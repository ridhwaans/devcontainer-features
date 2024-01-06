#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check plugin managers
check "non-root user antigen" ls -al /usr/local/share/.zsh/bundle
check "non-root user vundle" ls -al /usr/local/share/.vim/bundle/Vundle.vim

# Check language managers
check "check for nvm" nvm --version
check "check for sdkman" sdk version
check "check for rbenv" rbenv --version
check "check for pyenv" pyenv --version

# Report result
reportResults
