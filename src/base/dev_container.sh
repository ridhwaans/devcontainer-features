#!/bin/bash

reopen_in_container() {
    local IMAGE_NAME="${1:-"base"}"
    local CONTAINER_NAME="${2:-"instance"}"

    DOCKERFILE_CONTENT=$(cat <<'EOF'
FROM ubuntu

ARG CONTAINER_DIR=/usr/local/bin/bootstrap

RUN mkdir -p $CONTAINER_DIR

COPY install.sh $CONTAINER_DIR/

COPY scripts/ $CONTAINER_DIR/scripts/

WORKDIR $CONTAINER_DIR
EOF
)

    echo "Building Docker image..."

    #echo "$DOCKERFILE_CONTENT" | docker build --no-cache -t $IMAGE_NAME -
    docker build --no-cache -t "$IMAGE_NAME" . > build_log.txt 2>&1

    echo "Creating Docker container..."
    docker run -it --name "$CONTAINER_NAME" "$IMAGE_NAME"

    echo "Connecting to Docker container..."
    docker exec -it "$CONTAINER_NAME" /bin/bash
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