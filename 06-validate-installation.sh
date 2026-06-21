#!/bin/bash

echo "=========================================="
echo " Validating Entire Installation           "
echo "=========================================="

# Check if minikube is running
if ! minikube status &> /dev/null; then
    echo "ERROR: Minikube is not running."
    exit 1
fi

# Check Docker image
echo "Checking Docker image..."
eval $(minikube docker-env)
if docker images | grep -q "cowrie-honeypot"; then
    echo "OK: Docker image cowrie-honeypot found."
else
    echo "ERROR: Docker image cowrie-honeypot not found."
fi

# Check namespace
if kubectl get namespace honeypot &> /dev/null; then
    echo "OK: Namespace 'honeypot' exists."
else
    echo "ERROR: Namespace 'honeypot' not found."
fi

# Check pods
READY_PODS=$(kubectl get deployment cowrie-honeypot -n honeypot -o jsonpath='{.status.readyReplicas}')
if [ -n "$READY_PODS" ] && [ "$READY_PODS" -gt 0 ]; then
    echo "OK: $READY_PODS Cowrie pods are ready."
else
    echo "WARNING: No Cowrie pods are currently ready."
fi

# Check service
if kubectl get service cowrie-service -n honeypot &> /dev/null; then
    echo "OK: cowrie-service is configured."
else
    echo "ERROR: cowrie-service not found."
fi

echo "Validation complete!"
