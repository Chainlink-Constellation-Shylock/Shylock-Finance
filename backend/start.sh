# Name of the Docker image
IMAGE_NAME="shylock-backend"

# Port mapping (host:container)
PORT_MAPPING="3001:3001"

# Build the Docker image
echo "Building Docker image..."
docker build -t $IMAGE_NAME .

# Check if an old container exists and remove it
OLD_CONTAINER=$(docker ps -aq -f status=exited -f name=$IMAGE_NAME)

if [ -n "$OLD_CONTAINER" ]; then
    echo "Removing old container..."
    docker rm $OLD_CONTAINER
fi

# Run the Docker container
echo "Starting Docker container..."
docker run -p $PORT_MAPPING --name $IMAGE_NAME -d $IMAGE_NAME

echo "Container started successfully."
