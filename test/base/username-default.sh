#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check plugin managers
check "non-root user" ls /home/vscode/.zsh/bundle
check "non-root user" ls /home/vscode/.vim/bundle/Vundle.vim

# Report result
reportResults
