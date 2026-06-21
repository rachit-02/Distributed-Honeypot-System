#!/bin/bash
set -e

echo "=========================================="
echo " Demoing Kubernetes Auto-scaling & Healing"
echo "=========================================="

echo "Current Pods:"
kubectl get pods -n honeypot -l app=cowrie

echo -e "\n1. Scaling deployment to 5 replicas..."
kubectl scale deployment cowrie-honeypot -n honeypot --replicas=5
sleep 3
kubectl get pods -n honeypot -l app=cowrie

echo -e "\n2. Demonstrating Self-Healing (Deleting a Pod)..."
POD_TO_DELETE=$(kubectl get pods -n honeypot -l app=cowrie -o jsonpath='{.items[0].metadata.name}')
echo "Deleting pod: $POD_TO_DELETE"
kubectl delete pod $POD_TO_DELETE -n honeypot

echo -e "\nWatch as Kubernetes immediately recreates the pod:"
kubectl get pods -n honeypot -l app=cowrie -w
