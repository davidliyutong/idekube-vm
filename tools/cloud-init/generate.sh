#!/bin/bash

set -e

IMAGE_NAME="cloud-image-utils:latest"

# Check if Docker image exists
if ! docker image inspect ${IMAGE_NAME} >/dev/null 2>&1; then
    echo "Docker image ${IMAGE_NAME} not found, building..."
    docker build -t ${IMAGE_NAME} -f tools/cloud-init/Dockerfile .
else
    echo "Docker image ${IMAGE_NAME} already exists, skipping build."
fi

# Run cloud-localds
echo "Generating cloud-init.iso using cloud-localds..."
docker run --rm -v $(pwd):/workspace ${IMAGE_NAME} cloud-localds ./assets/cloud-init.iso ./user-data.yaml ./meta-data.yaml
echo "cloud-init.iso generated at ./assets/cloud-init.iso"