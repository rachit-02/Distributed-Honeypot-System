#!/bin/bash

echo "=========================================="
echo " Testing Honeypot Deployment              "
echo "=========================================="

echo "1. Checking Pod Status..."
kubectl get pods -n honeypot -l app=cowrie

echo -e "\n2. Checking Services..."
kubectl get svc -n honeypot cowrie-service

# Get Minikube IP
MINIKUBE_IP=$(minikube ip)

echo -e "\n3. Testing SSH Connectivity (Expect 'Permission denied' or similar SSH rejection)..."
echo "Command: ssh -p 30222 root@$MINIKUBE_IP"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 30222 root@$MINIKUBE_IP

echo -e "\n4. Fetching recent logs from a pod..."
POD_NAME=$(kubectl get pods -n honeypot -l app=cowrie -o jsonpath='{.items[0].metadata.name}')
kubectl logs -n honeypot $POD_NAME --tail=20
