#!/bin/bash
set -e

echo "=========================================="
echo " Setting up Kubernetes (Minikube) cluster "
echo "=========================================="

# Check if minikube is installed
if ! command -v minikube &> /dev/null; then
    echo "minikube not found. Please install minikube and docker first."
    echo "For Ubuntu/Debian:"
    echo "  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64"
    echo "  sudo install minikube-linux-amd64 /usr/local/bin/minikube"
    exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Please install kubectl."
    echo "For Ubuntu/Debian:"
    echo "  sudo apt-get update && sudo apt-get install -y kubectl"
    exit 1
fi

# Detect problematic kubectl installations (e.g. symlink into /mnt/docker-desktop)
KUBECTL_PATH=$(command -v kubectl || true)
if [ -n "$KUBECTL_PATH" ]; then
    if readlink "$KUBECTL_PATH" 2>/dev/null | grep -qE "/mnt/|docker-desktop"; then
        echo "WARNING: detected kubectl at $KUBECTL_PATH pointing into a mounted /mnt path."
        echo "This kubectl (from Docker Desktop / WSL mount) can crash (SIGBUS) when used in pipelines."
        echo "Recommended fix: install a native kubectl binary and replace the symlink."
        echo "To install the native kubectl run the following (one-liner):"
        echo "  ARCH=amd64; if [ \$(uname -m) = aarch64 ]; then ARCH=arm64; fi; \
  curl -LO \"https://dl.k8s.io/release/\$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$ARCH/kubectl\" && \
  chmod +x kubectl && sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm -f kubectl"
        echo "Alternatively, re-run this script after installing a native kubectl."
        exit 1
    fi
fi

echo "Starting minikube..."
minikube start --nodes 1 --driver=docker

echo "Creating honeypot namespace..."
kubectl create namespace honeypot --dry-run=client -o yaml | kubectl apply -f -

echo "Setup complete. Cluster is running."
