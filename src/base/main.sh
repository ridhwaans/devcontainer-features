#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

source ./scripts/helpers.sh

install-exercism() {
  curl -L https://github.com/exercism/cli/releases/download/v3.1.0/exercism-3.1.0-linux-x86_64.tar.gz -o exercism-3.1.0-linux-x86_64.tar.gz
	tar -xf exercism-3.1.0-linux-x86_64.tar.gz
	mkdir -p $HOME/bin && mv exercism $_
	$HOME/bin/exercism
	rm -rf exercism-3.1.0-linux-x86_64.tar.gz
}

install-gh-cli(){
  curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
  && sudo apt update \
  && sudo apt install gh -y

  extensions=(
    GitHub.codespaces
    GitHub.copilot
  )
  if type -p code >/dev/null
  then
    for extension in "${extensions[@]}"
    do
      code --install-extension $extension
    done
  fi
}

install-go(){
  packages=(
		golang-go
	)
	echo "Installing packages..."
	sudo apt install -y "${packages[@]}"
}

install-javascript(){
  version_manager_exists nvm
  if [ $? -ne 0 ]; then
    # Install version manager
    git clone https://github.com/nvm-sh/nvm.git ~/.nvm

    updaterc 'export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")'
    updaterc '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'
  fi

  if [[ "$(node -v)" = *"${NODE_VERSION}"* ]]; then
    echo "(!) Node is already installed with version ${NODE_VERSION}. Skipping..."
  elif [ "${NODE_VERSION}" != "none" ]; then
    echo "Installing specified Python version."
    su ${USERNAME} -c "nvm install ${NODE_VERSION}"
  fi

  extensions=(
    dbaeumer.vscode-eslint
  )
  if type -p code >/dev/null
  then
    for extension in "${extensions[@]}"
    do
      code --install-extension $extension
    done
  fi
}

install-python() {
  version_manager_exists pyenv
  if [ $? -ne 0 ]; then
    # Install version manager
      git clone https://github.com/pyenv/pyenv.git ~/.pyenv

      echo "Setting up pyenv plugins..."
      git clone https://github.com/pyenv/pyenv-virtualenv.git .pyenv/plugins/pyenv-virtualenv

      updaterc 'export PYENV_ROOT="$HOME/.pyenv"'
      updaterc '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
      updaterc 'eval "$(pyenv init -)"'
      updaterc 'eval "$(pyenv virtualenv-init -)"'
  fi

  if [[ "$(python -v)" = *"${PYTHON_VERSION}"* ]]; then
    echo "(!) Python is already installed with version ${PYTHON_VERSION}. Skipping..."
  elif [ "${PYTHON_VERSION}" != "none" ]; then
    echo "Installing specified Python version."
    su ${USERNAME} -c "pyenv install python ${PYTHON_VERSION}"
  fi
}

install-ruby() {
  version_manager_exists rbenv
  if [ $? -ne 0 ]; then
    # Install version manager
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv

    echo "Setting up rbenv plugins..."
    git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
    git clone https://github.com/jf/rbenv-gemset.git ~/.rbenv/plugins/rbenv-gemset

    updaterc 'export RBENV_ROOT="$HOME/.pyenv"'
    updaterc '[[ -d $RBENV_ROOT/bin ]] && export PATH="$RBENV_ROOT/bin:$PATH"'
    updaterc 'eval "$(rbenv init -)"'
  fi

  if [[ "$(ruby -v)" = *"${RUBY_VERSION}"* ]]; then
    echo "(!) Ruby is already installed with version ${RUBY_VERSION}. Skipping..."
  elif [ "${RUBY_VERSION}" != "none" ]; then
    echo "Installing specified Ruby version."
    su ${RUBY_VERSION} -c "rbenv install ruby ${RUBY_VERSION}"
  fi

  extensions=(
    shopify.ruby-lsp
    sorbet.sorbet-vscode-extension
    rubocop.vscode-rubocop
  )
  if type -p code >/dev/null
  then
    for extension in "${extensions[@]}"
    do
      code --install-extension $extension
    done
  fi
}

install-java() {
  version_manager_exists sdk
  if [ $? -ne 0 ]; then
    # Install version manager
    curl -s "https://get.sdkman.io" | bash

    updaterc 'export SDKMAN_DIR="$HOME/.sdkman"'
    updaterc '[[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]] && source "$SDKMAN_DIR/bin/sdkman-init.sh"'
  fi
}

install-aws-terraform() {
  packages=(
		awscli
	)
	echo "Installing packages..."
	sudo apt install -y "${packages[@]}"

	curl -L https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip --create-dirs -o $HOME/aws-sam-cli-linux-x86_64.zip && cd $(dirname $_)
	unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
	sudo ./sam-installation/install
	rm -rf sam-installation
	rm -rf aws-sam-cli-linux-x86_64.zip

  pip install cfn-lint

  curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
  sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
  sudo apt update
  sudo apt install terraform

  extensions=(
    hashicorp.hcl
    hashicorp.terraform
  )
  if type -p code >/dev/null
  then
    for extension in "${extensions[@]}"
    do
      code --install-extension $extension
    done
  fi
}

install-databases(){
  packages=(
		mysql-server
		postgresql postgresql-contrib
	)
	echo "Installing packages..."
	sudo apt install -y "${packages[@]}"

  extensions=(
    Prisma.prisma
  )
  if type -p code >/dev/null
  then
    for extension in "${extensions[@]}"
    do
      code --install-extension $extension
    done
  fi
}
