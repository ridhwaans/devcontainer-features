# Export all variables and make them available to child processes & scripts invoked from within main script

export USERNAME="${USERNAME:-"automatic"}"
export USER_UID="${USERUID:-"automatic"}"
export USER_GID="${USERGID:-"automatic"}"
export UPDATE_RC="${UPDATERC:-"true"}"
export VUNDLE_DIR="${VUNDLEDIR:-"/usr/local/share/.vim/bundle"}"
export VIMRC_PATH="${VIMRCPATH:-"/etc/vim/vimrc"}"
export ANTIGEN_DIR="${ANTIGENDIR:-"/usr/local/share/.zsh/bundle"}"
export ZSHRC_PATH="${ZSHRCPATH:-"/etc/zsh/zshrc"}"
export BASHRC_PATH="${BASHRCPATH:-"/etc/bash.bashrc"}"
export SET_THEME="${SETTHEME:-"true"}"

export JAVA_VERSION="${JAVAVERSION:-"lts"}"
export INSTALL_GRADLE="${INSTALLGRADLE:-"false"}"
export GRADLE_VERSION="${GRADLEVERSION:-"latest"}"
export INSTALL_MAVEN="${INSTALLMAVEN:-"false"}"
export MAVEN_VERSION="${MAVENVERSION:-"latest"}"
export SDKMAN_INSTALL_PATH="${SDKMANINSTALLPATH:-"/usr/local/sdkman"}"
export JAVA_ADDITIONAL_VERSIONS="${JAVAADDITIONALVERSIONS:-""}"

export PYTHON_VERSION="${PYTHONVERSION:-"latest"}"
export PYENV_INSTALL_PATH="${PYENVINSTALLPATH:-"/usr/local/pyenv"}"
export PYTHON_ADDITIONAL_VERSIONS="${PYTHONADDITIONALVERSIONS:-""}"

export RUBY_VERSION="${RUBYVERSION:-"latest"}"
export RBENV_INSTALL_PATH="${RBENVINSTALLPATH:-"/usr/local/rbenv"}"
export RUBY_ADDITIONAL_VERSIONS="${RUBYADDITIONALVERSIONS:-""}"

export NODE_VERSION="${NODEVERSION:-"latest"}"
export NVM_INSTALL_PATH="${NVMINSTALLPATH:-"/usr/local/nvm"}"
export NODE_ADDITIONAL_VERSIONS="${NODEADDITIONALVERSIONS:-""}"

export GO_VERSION="${GOVERSION:-"latest"}"
export GO_DIR="${GOINSTALLPATH:-"/usr/local/go"}"
export GO_PATH="${GOPATH:-"/go"}"

export EXERCISM_VERSION="${EXERCISMVERSION:-"latest"}"
export TERRAFORM_VERSION="${TERRAFORMVERSION:-"latest"}"