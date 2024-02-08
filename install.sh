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

install_local() {
    sudo bash -c "cd src/base && ./install.sh"
}

# Function to display the Docker installation menu
docker_installation_menu() {
    containers=$(docker ps -a --format '{{.Names}}')
    if [ "$containers" ]; then
        echo "Existing Docker containers:"
        echo "$containers"
    fi

    echo ""
    images=$(docker images --format '{{.Repository}}:{{.Tag}}')
    if [ "$images" ]; then
        echo "Existing Docker images:"
        echo "$images"
    fi

    echo ""
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
                    read -p "Enter the name for the Docker container: " container_name
                    install_in_container
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