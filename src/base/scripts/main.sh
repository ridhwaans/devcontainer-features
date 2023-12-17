#!/bin/bash

set -e

if [ "$(id -u)" -ne 0 ]; then
  echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
  exit 1
fi

install-exercism() {
  curl -L https://github.com/exercism/cli/releases/download/v3.1.0/exercism-3.1.0-linux-x86_64.tar.gz -o exercism-3.1.0-linux-x86_64.tar.gz
	tar -xf exercism-3.1.0-linux-x86_64.tar.gz
	mkdir -p $HOME/bin && mv exercism $_
	$HOME/bin/exercism
	rm -rf exercism-3.1.0-linux-x86_64.tar.gz
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
