# Start from a base image with Node.js (adjust version as needed)
FROM node:latest

# Install Deno
RUN curl -fsSL https://deno.land/x/install/install.sh | sh

# Install ts-node
RUN npm install -g ts-node

# Add Deno to the path
ENV PATH="/root/.deno/bin:$PATH"

# Set the working directory in the Docker container
WORKDIR /app

# Copy the package.json and package-lock.json files
COPY package*.json ./

# Install npm dependencies
RUN npm install

# Copy the rest of code
COPY . .

# Server's port
EXPOSE 3000

# Command to run the app
CMD ["npm", "start"]