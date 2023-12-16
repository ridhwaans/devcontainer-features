#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check plugin managers
check "non-root user zsh" ls /home/vscode/.zsh/bundle
check "non-root user vim" ls /home/vscode/.vim/bundle/Vundle.vim

# Report result
reportResults
