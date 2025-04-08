#!/bin/bash
set -e
# Wait for any existing apt locks to clear
echo "Checking for apt locks..."
while sudo lsof /var/lib/apt/lists/lock >/dev/null 2>&1 || \
      sudo lsof /var/lib/dpkg/lock >/dev/null 2>&1 || \
      sudo lsof /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Another apt process is running. Waiting 10 seconds..."
  sleep 10
done

echo "Updating system and installing Docker..."
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

echo "Stopping old Django container if exists..."
sudo docker stop django-container || true
sudo docker rm django-container || true

echo "Pulling latest Docker image..."
sudo docker pull nikitalimbu/helloworld-django:latest

echo "Running Django container..."
sudo docker run -d -p 8000:8000 --name django-container nikitalimbu/helloworld-django:latest

echo "✅ Deployment finished!"
