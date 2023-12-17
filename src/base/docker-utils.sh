#!/bin/bash

# Function to build Docker image, create container, and connect to it in a Bash shell
build_container_and_connect() {

DOCKERFILE_CONTENT=$(cat <<EOF
# Use the official Ubuntu image as the base image
FROM ubuntu AS builder

ARG HOST_DIR=/home/ridhwaans/Source/devcontainer-features/src/base
ARG CONTAINER_DIR=/usr/local/bin/bootstrap

# Create a directory for the bootstrap scripts
RUN mkdir -p /usr/local/bin/bootstrap

# Copy the install.sh script and the contents of the scripts directory into the container
COPY \$HOST_DIR/install.sh \$CONTAINER_DIR
COPY \$HOST_DIR/scripts/ \$CONTAINER_DIR/scripts/

# Set the working directory to the bootstrap directory
WORKDIR \$CONTAINER_DIR

# Run the install.sh script during the build process
RUN ./install.sh

# Use a smaller image for the final image
FROM ubuntu

# Copy files from the builder stage
COPY --from=builder /usr/local/bin/bootstrap /usr/local/bin/bootstrap

# Set the working directory to the bootstrap directory
WORKDIR /usr/local/bin/bootstrap

# Set the default command to run when the container starts
CMD ["bash"]
EOF
)

    local IMAGE_NAME="$1"
    local CONTAINER_NAME="$2"

    # Step 1: Build Docker image
    echo "Building Docker image..."
    echo "$DOCKERFILE_CONTENT" | DOCKER_BUILDKIT=0 docker build --no-cache -t $IMAGE_NAME -

    # Step 2: Create Docker container
    echo "Creating Docker container..."
    docker run -it --name "$CONTAINER_NAME" "$IMAGE_NAME"

    # Step 3: Connect to the Docker container in a Bash shell
    echo "Connecting to Docker container..."
    docker exec -it "$CONTAINER_NAME" /bin/bash
}


# Function to stop and delete a Docker container and its corresponding image
cleanup_container_and_image() {
    local CONTAINER_NAME="$1"
    local IMAGE_NAME="$2"

    # Check if the container exists and stop it
    if docker ps -a --format '{{.Names}}' | grep -q "$CONTAINER_NAME"; then
        echo "Stopping and removing container: $CONTAINER_NAME"
        docker stop "$CONTAINER_NAME" && docker rm "$CONTAINER_NAME"
    else
        echo "Container $CONTAINER_NAME not found."
    fi

    # Check if the image exists and remove it
    if docker images --format '{{.Repository}}:{{.Tag}}' | grep -q "$IMAGE_NAME"; then
        echo "Removing image: $IMAGE_NAME"
        docker rmi "$IMAGE_NAME"
    else
        echo "Image $IMAGE_NAME not found."
    fi
}