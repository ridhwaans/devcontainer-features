#!/usr/bin/env bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

echo "~/.bashrc is:"
cat ~/.bashrc
echo "~/.zshrc is:"
cat ~/.zshrc

echo "PATH is $PATH"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo "The file $NVM_DIR/nvm.sh exists and is not empty."
fi

pwd
ls -al
echo ~/
ls -al ~/

cat /etc/passwd
echo "id of current user $(whoami) is $(id -u)"

# common-utils
check "should be logged in as the created user" echo $(whoami) | grep "customUser"
check "user should have a uid of 1055" echo $(id -nu 1055) | grep "customUser"
check "user default shell should be zsh" bash -c "getent passwd $(whoami) | awk -F: '{ print $7 }' | grep '/bin/zsh'"
check "user default timezone should be UTC" echo $(date +%Z) | grep "UTC"

check "zsh version" zsh --version
check "vim version" vim --version | head -n 1

VIMPLUG_PATH="/usr/local/share/vim/bundle"
check "check for vim-plug" ls -1 $VIMPLUG_PATH/autoload/plug.vim | wc -l

source ~/.bashrc

# Check language managers
check "check for nvm" nvm --version
check "check for sdkman" sdk version
check "check for rbenv" rbenv --version
check "check for pyenv" pyenv --version

# Check language versions
check "check for node" node --version
check "check for java" java --version
check "check for ruby" ruby --version
check "check for python" python --version
check "check for go" go version

# Check tool versions
check "check for aws" aws --version
check "check for sam" sam --version
check "check for cfn-lint" cfn-lint --version
check "check for terraform" terraform -version
check "check for gh" gh --version
check "check for exercism" exercism version

# Report result
reportResults
