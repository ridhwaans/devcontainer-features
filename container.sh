#!/bin/bash

perform_install() {
    # Step 1: Create directory /usr/local/bin/bootstrap if it doesn't exist
    docker exec -it "$CONTAINER_NAME" bash -c '[ -d "$STARTING_DIR" ] || mkdir -p "$STARTING_DIR"'

    # Step 2: Copy install.sh and scripts/ from the host machine into the container
    docker cp install.sh "$CONTAINER_NAME":$STARTING_DIR
    docker cp scripts/ "$CONTAINER_NAME":$STARTING_DIR

    # Step 3: Connect into the container and run install.sh
    docker exec -it "$CONTAINER_NAME" /bin/bash -c 'cd "$STARTING_DIR" && ./install.sh'
}


build_image() {
    DOCKERFILE_CONTENT=$(cat <<'EOF'
ARG DISTRIBUTION=debian

ARG RELEASE=stable

FROM $DISTRIBUTION:$RELEASE

ARG CLIENT_DIR=src/base

ARG WORKING_DIR=/usr/local/bin/bootstrap

RUN mkdir -p $WORKING_DIR

COPY $CLIENT_DIR/install.sh $WORKING_DIR/

COPY $CLIENT_DIR/scripts/ $WORKING_DIR/scripts/

WORKDIR $WORKING_DIR
EOF
)

    echo "Building Docker image..."
    # Check if Dockerfile exists in the current directory
    if [ -f Dockerfile ]; then
        # Use the local Dockerfile
        docker build --no-cache -t "$IMAGE_NAME" . > build_log.txt 2>&1
    else
        # Use the inline Dockerfile content
        echo "$DOCKERFILE_CONTENT" | docker build --no-cache -t "$IMAGE_NAME" -
    fi
}

install_in_container() {
    local DISTRIBUTION="${1:-"debian"}"
    local RELEASE="${2:-"stable"}"
    local IMAGE_NAME="${3:-"base"}"
    local CONTAINER_NAME="${4:-"instance"}"
    local CLIENT_DIR="${5:-"src/base"}"
    local WORKING_DIR="${6:-"/usr/local/bin/bootstrap"}"

    # Check if the container exists and is already running
    if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME 2>/dev/null)" = "true" ]; then
        echo "Container $CONTAINER_NAME is already running."
        
        perform_install
    else
        # Check if the container exists but is stopped
        if [ "$(docker inspect -f '{{.State.Status}}' $CONTAINER_NAME 2>/dev/null)" = "exited" ]; then

            echo "Starting existing $CONTAINER_NAME..."

            # Start the existing stopped container
            docker start -i $CONTAINER_NAME

            perform_install
        else
            # Container does not exist
            build_image

            echo "Starting new container $CONTAINER_NAME..."

            # Create and start a new container
            docker run -it --name $CONTAINER_NAME $IMAGE_NAME
        fi
    fi

    echo "Connecting to Docker container..."
    perform_install

    # Create and start a new container but do not run anything
    # docker run -it --name $CONTAINER_NAME $IMAGE_NAME
}

cleanup_container() {
    local IMAGE_NAME="${1:-"base"}"
    local CONTAINER_NAME="${2:-"instance"}"

    if docker ps -a --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
        echo "Stopping and removing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
    else
        echo "Container $CONTAINER_NAME not found."
    fi

    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$IMAGE_NAME"; then
        echo "Removing image: $IMAGE_NAME"
        docker rmi "$IMAGE_NAME"
    else
        echo "Image $IMAGE_NAME not found."
    fi
}