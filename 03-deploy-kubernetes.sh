#!/bin/bash
set -e

echo "=========================================="
echo " Deploying to Kubernetes                  "
echo "=========================================="

# Create namespace safely (avoid piping between two kubectl processes which can
# trigger crashes when kubectl is a problematic binary on mounted filesystems)
create_and_apply_namespace() {
	TMPFILE=$(mktemp /tmp/honeypot-namespace.XXXX.yaml)
	kubectl create namespace honeypot --dry-run=client -o yaml > "$TMPFILE"
	kubectl apply -f "$TMPFILE"
	rm -f "$TMPFILE"
}

echo "Creating namespace 'honeypot' (safe apply)..."
create_and_apply_namespace

echo "Applying ConfigMap..."
kubectl apply -f configmap.yaml

echo "Applying Deployment..."
kubectl apply -f deployment.yaml

echo "Applying Service..."
kubectl apply -f service.yaml

echo "Waiting for deployment rollout to complete (120s timeout)..."
if ! kubectl -n honeypot rollout status deployment/cowrie-honeypot --timeout=120s; then
	echo "Rollout did not complete within timeout. Showing pod status and recent logs."
	kubectl get pods -n honeypot -o wide
	echo "-- Recent logs from pods --"
	kubectl logs -n honeypot -l app=cowrie --tail=100 || true
	exit 1
fi

echo "Pods are initializing; attach to pod events (ctrl-C to exit)..."
kubectl get pods -n honeypot -w
