#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Check plugin managers
check "non-root user antigen" ls -al /usr/local/share/.zsh/bundle
check "non-root user vundle" ls -al /usr/local/share/.vim/bundle/Vundle.vim

# Report result
reportResults
