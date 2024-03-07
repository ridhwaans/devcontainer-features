ARG DISTRIBUTION=debian

ARG RELEASE=stable

FROM $DISTRIBUTION:$RELEASE

# Required for first time sudo commands
RUN apt-get update && apt-get install -y sudo

ARG SOURCE=.

ARG DESTINATION=/usr/local/bin/bootstrap

RUN mkdir -p $DESTINATION

COPY $SOURCE/. $DESTINATION
