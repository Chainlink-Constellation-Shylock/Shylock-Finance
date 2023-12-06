# Name of the Docker image
IMAGE_NAME="shylock-backend"

# Find the container ID based on the image name
CONTAINER_ID=$(docker ps -q -f ancestor=$IMAGE_NAME)

if [ -z "$CONTAINER_ID" ]; then
    echo "No running container found for image $IMAGE_NAME"
    exit 1
fi

# Stop the running container
echo "Stopping the Docker container with ID $CONTAINER_ID..."
docker stop $CONTAINER_ID

# Remove the stopped container
echo "Removing the Docker container with ID $CONTAINER_ID..."
docker rm $CONTAINER_ID

echo "Container stopped and removed successfully."
