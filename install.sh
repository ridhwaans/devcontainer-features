#!/bin/bash

source container.sh

which_env() {
  if [ $(uname) = Darwin ]; then
    return "(mac)"
  elif [ $(uname) = Linux ]; then
    if [ -n "$WSL_DISTRO_NAME" ]; then
      return "(wsl)"
    elif [ -n "$CODESPACES" ]; then
      return "(github codespaces)"
    else
		  return "(native linux)"
    fi
  fi
}

echo "Checking existing Docker containers..."
containers=$(docker ps -a --format '{{.Names}}')

if [ -z "$containers" ]; then
    echo "No existing Docker containers found."
else
    echo "Existing Docker containers:"
    echo "$containers"
fi

echo ""

echo "Checking existing Docker images..."
images=$(docker images --format '{{.Repository}}:{{.Tag}}')

if [ -z "$images" ]; then
    echo "No existing Docker images found."
else
    echo "Existing Docker images:"
    echo "$images"
fi

echo ""
# Function to display the Docker installation menu
docker_installation_menu() {
    echo "Select Docker installation type:"
    echo "1. Install into Docker container"
    echo "2. Go back to previous menu"
}

# Ask the user for installation type
echo "Select installation type:"
echo "1. Install directly on the local machine (dockerless)"
echo "2. Install using Docker"
read -p "Enter your choice (1 or 2): " choice

# Check the user's choice and proceed accordingly
case $choice in
    1)
        echo "Installing directly on the local machine..."
        # Add your local machine installation commands here
        ;;
    2)
        echo "Installing using Docker..."
        while true; do
            docker_installation_menu
            read -p "Enter your choice (1 or 2): " docker_choice
            case $docker_choice in
                1)
                    read -p "Enter the name for the new Docker container: " container_name
                    echo "Installing into a new Docker container named $container_name..."
                    # Add your installation commands for a new Docker container here
                    ;;
                2)
                    break  # Go back to previous menu
                    ;;
                *)
                    echo "Invalid choice. Please enter 1 or 2."
                    ;;
            esac
        done
        ;;
    *)
        echo "Invalid choice. Please enter 1 or 2."
        ;;
esac

echo "Done"