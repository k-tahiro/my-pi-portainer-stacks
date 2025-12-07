#!/usr/bin/env bash

# Get the code
wget -O compose.yaml https://github.com/immich-app/immich/releases/latest/download/docker-compose.yml
wget -O .env https://github.com/immich-app/immich/releases/latest/download/example.env

# env_fileをyqで../stack.envに置換（env_file指定があるものだけ）
if command -v yq >/dev/null 2>&1; then
    yq -i '(.services[] | select(.env_file)) |= .env_file = ["../stack.env"]' compose.yaml
    echo "env_file replaced with ../stack.env for services with env_file using yq"
else
    echo "yq is not installed. Please install yq to use this feature."
fi
