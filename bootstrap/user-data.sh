#!/bin/bash

# Exit immediately if any command fails.
set -e

# Update package index.
apt-get update -y

apt-get install -y docker.io

apt-get install -y \
    curl \
    ca-certificates \
    docker.io

systemctl enable docker
systemctl start docker

mkdir -p /usr/local/lib/docker/cli-plugins

curl -SL \
https://github.com/docker/compose/releases/download/v2.39.4/docker-compose-linux-x86_64 \
-o /usr/local/lib/docker/cli-plugins/docker-compose

chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Add the ubuntu user to the docker group.
usermod -aG docker ubuntu13.235.9.133