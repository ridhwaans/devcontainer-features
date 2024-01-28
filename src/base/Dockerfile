ARG BASE_IMAGE_VERSION=latest

FROM ubuntu:$BASE_IMAGE_VERSION

ARG WORKING_DIR=/usr/local/bin/bootstrap

RUN mkdir -p $WORKING_DIR

COPY install.sh $WORKING_DIR/

COPY scripts/ $WORKING_DIR/scripts/

WORKDIR $WORKING_DIR