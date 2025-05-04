#!/bin/bash
set -e

echo "✅ Starting optimized deploy.sh"

# Wait for any existing apt locks to clear
echo "Checking for apt locks..."
while sudo lsof /var/lib/apt/lists/lock >/dev/null 2>&1 || \
      sudo lsof /var/lib/dpkg/lock >/dev/null 2>&1 || \
      sudo lsof /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Another apt process is running. Waiting 10 seconds..."
  sleep 10
done

echo "Updating system and installing Docker..."

# Installing Docker and Curl (will only install if not already installed)
for i in {1..5}; do
  if sudo apt update -y && sudo apt install -y docker.io curl; then
    break
  else
    echo "apt failed. Retry $i/5 in 10 seconds..."
    sleep 10
  fi
done

echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Installing Docker Compose v2..."
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

docker compose version

# Stopping and removing old Django container
echo "Stopping old Django container if exists..."
sudo docker stop django-container || true
sudo docker rm django-container || true

# Pulling the latest Docker image
echo "Pulling latest Docker image..."
sudo docker pull nikitalimbu/helloworld-django:latest

# Load environment variables
echo "Loading environment variables..."
set -a
source /etc/environment
set +a

# Run the new container with updated environment variables
echo "Running new container..."
sudo docker run -d -p 8000:8000 --name django-container \
  -e COGNITO_DOMAIN=${COGNITO_DOMAIN} \
  -e COGNITO_CLIENT_ID=${COGNITO_CLIENT_ID} \
  -e COGNITO_CLIENT_SECRET=${COGNITO_CLIENT_SECRET} \
  nikitalimbu/helloworld-django:latest

echo "✅ Deployment complete!"
