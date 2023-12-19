FROM ubuntu

ARG CONTAINER_DIR=/usr/local/bin/bootstrap

RUN mkdir -p $CONTAINER_DIR

COPY install.sh $CONTAINER_DIR/

COPY scripts/ $CONTAINER_DIR/scripts/

WORKDIR $CONTAINER_DIR