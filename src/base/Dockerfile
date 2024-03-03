ARG DISTRIBUTION=debian

ARG RELEASE=stable

FROM $DISTRIBUTION:$RELEASE

ARG CLIENT_DIR=.

ARG WORKING_DIR=/usr/local/bin/bootstrap

RUN mkdir -p $WORKING_DIR

COPY $CLIENT_DIR/install.sh $WORKING_DIR/

COPY $CLIENT_DIR/scripts/ $WORKING_DIR/scripts/

# Required for first time sudo commands
RUN apt-get update && apt-get install -y sudo

WORKDIR $WORKING_DIR