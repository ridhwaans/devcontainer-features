#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

USERNAME="${USERNAME:-"${_REMOTE_USER:-"automatic"}"}"

# Install gh-cli
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
apt update 
apt install -y --no-install-recommends gh

# Install exercism-cli
curl -L https://github.com/exercism/cli/releases/download/v3.1.0/exercism-3.1.0-linux-x86_64.tar.gz -o exercism-3.1.0-linux-x86_64.tar.gz
tar -xf exercism-3.1.0-linux-x86_64.tar.gz
mkdir -p $HOME/bin && mv exercism $_
$HOME/bin/exercism
rm -rf exercism-3.1.0-linux-x86_64.tar.gz


# Install AWS
if command -v aws &> /dev/null; then
  echo "aws is installed. Version: $(aws --version)"
else
  apt install -y --no-install-recommends awscli
fi

# Install SAM
if command -v sam &> /dev/null; then
    echo "sam is installed. Version: $(sam --version)"
else
  curl -L https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip --create-dirs -o /tmp/aws-sam-cli-linux-x86_64.zip && cd $(dirname $_)
	unzip aws-sam-cli-linux-x86_64.zip -d sam-installation
	./sam-installation/install
	rm -rf sam-installation
	rm -rf aws-sam-cli-linux-x86_64.zip
fi

# Install cfn-lint
pip install cfn-lint

# Install terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install -y --no-install-recommends terraform


