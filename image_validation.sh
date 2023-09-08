#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Set the name of the image and container for easy reference
IMAGE_NAME="test_image"
CONTAINER_NAME="test_container"

# Try to remove any existing container with the same name (ignoring errors)
echo -e "${YELLOW}Attempting to remove any existing container with name $CONTAINER_NAME...${NC}"
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Build the Docker image
echo -e "${YELLOW}Building Docker image...${NC}"
docker build -t $IMAGE_NAME .

# Run the container in detached mode and override the default entry point
echo -e "${YELLOW}Running container with overridden entry point...${NC}"
docker run -d --entrypoint /bin/pwsh --name $CONTAINER_NAME $IMAGE_NAME -c "while(\$true){Start-Sleep 10}"

# Commands to test
COMMANDS=("dotnet --version" "dotnet build -h" "node -v" "az --version" "pwsh -version" "sqlpackage /version" "pwsh -Command 'Get-InstalledModule -Name Az'")

# Loop through each command to test it
for cmd in "${COMMANDS[@]}"; do
  echo -e "${YELLOW}Testing command: $cmd${NC}"
  # Run the command in the running container
  docker exec -it $CONTAINER_NAME pwsh -c "$cmd"
  # Check if the command was successful
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Command $cmd executed successfully.${NC}"
  else
    echo -e "${RED}Command $cmd failed.${NC}"
  fi
done

# Stop and remove the container
echo -e "${YELLOW}Stopping and removing container...${NC}"
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

# Remove the Docker image
echo -e "${YELLOW}Removing Docker image...${NC}"
docker rmi $IMAGE_NAME

echo -e "${GREEN}Done!${NC}"
