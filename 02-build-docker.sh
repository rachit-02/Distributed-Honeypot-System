#!/bin/bash
set -e

echo "=========================================="
echo " Building Cowrie Docker Image             "
echo "=========================================="

# Ensure minikube is running
if ! minikube status &> /dev/null; then
    echo "Minikube is not running. Please start minikube first."
    exit 1
fi

echo "Setting docker environment to minikube..."
eval $(minikube docker-env)

# Get version from file or environment, default to v1.0.0
VERSION=${COWRIE_VERSION:-v1.0.0}
echo "Building Docker image cowrie-honeypot:${VERSION}..."
docker build -t cowrie-honeypot:${VERSION} -t cowrie-honeypot:latest -f Dockerfile .

echo "Image built successfully."
echo "Version: ${VERSION}"

echo "Build successful."
