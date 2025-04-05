#!/bin/bash
set -e

echo "Updating system and installing Docker..."
sudo apt update -y
sudo apt install -y docker.io curl

echo "Starting and enabling Docker..."
sudo systemctl start docker
sudo systemctl enable docker

echo "Installing Docker Compose v2..."
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.22.0/docker-compose-linux-x86_64 -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

docker compose version

echo "Stopping old Django container if exists..."
sudo docker stop django-container || true
sudo docker rm django-container || true

echo "Pulling latest Docker image..."
sudo docker pull nikitalimbu/helloworld-django:latest

echo "Running Django container..."
sudo docker run -d -p 8000:8000 --name django-container nikitalimbu/helloworld-django:latest

echo "✅ Deployment finished!"
