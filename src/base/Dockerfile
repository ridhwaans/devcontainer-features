FROM ubuntu

RUN mkdir -p /usr/local/bin/bootstrap
COPY install.sh /usr/local/bin/bootstrap
COPY scripts/ /usr/local/bin/bootstrap/scripts/

# dockerfile fix tzdata getting stuck during build image
# https://askubuntu.com/questions/909277/avoiding-user-interaction-with-tzdata-when-installing-certbot-in-a-docker-contai
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /usr/local/bin/bootstrap

# cd ~/Source/devcontainer-features/src/base
# docker build . -t name:tag --progress=plain --no-cache
# docker run --detach --interactive --tty name:tag
# cd /usr/local/bin/bootstrap
# cat "/usr/local/bin/bootstrap/scripts/zshrc_snippet" >> ~/zshrc
# stop_and_remove_containers name:tag