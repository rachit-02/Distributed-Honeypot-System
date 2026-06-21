# Troubleshooting & FAQ

## Prerequisites Issues

### "kubeadm command not found"
```bash
# Verify installation
which kubeadm

# If not found, reinstall:
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubeadm kubelet kubectl
```

### "docker command not found"
```bash
# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
```

### "Permission denied" with docker commands
```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Activate group changes
newgrp docker

# Verify
docker ps
```

### "Swap is enabled" error during kubeadm init
```bash
# Disable swap
sudo swapoff -a

# Make permanent
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# Verify
free -h  # Should show 0 for swap
```

---

## Cluster Initialization Issues

### "kubeadm init" hangs or fails
```bash
# Check prerequisites
sudo modprobe overlay
sudo modprobe br_netfilter

# Check sysctl
cat /etc/sysctl.d/99-kubernetes.conf

# Retry init with verbose output
sudo kubeadm init --v=5 \
  --apiserver-advertise-address=$(hostname -I | awk '{print $1}') \
  --pod-network-cidr=10.244.0.0/16
```

### "kubeconfig: connection refused"
```bash
# Setup kubeconfig
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Test connection
kubectl cluster-info
```

### "Nodes stuck in NotReady"
```bash
# Check node status
kubectl get nodes

# Describe problem
kubectl describe node <node-name>

# Common causes:
# 1. Network plugin not installed
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# 2. Kubelet service not running
sudo systemctl restart kubelet

# 3. Check kubelet logs
sudo journalctl -u kubelet -f
```

---

## Docker Issues

### "failed to build image"
```bash
# Check Docker is running
sudo systemctl status docker

# Build with verbose output
docker build -t cowrie-honeypot:latest -f Dockerfile . -v

# Common issues:
# - Network timeout: retry build
# - Disk space: docker system prune
# - Base image not found: docker pull ubuntu:22.04
```

### "Image not found" during docker run
```bash
# List images
docker images

# If not there, rebuild
docker build -t cowrie-honeypot:latest .

# Verify
docker images | grep cowrie
```

### "docker: unauthorized" when pushing
```bash
# Login to registry
docker login                    # Docker Hub
docker login gcr.io            # Google
docker login [registry-url]    # Custom

# Tag correctly for your registry
docker tag cowrie-honeypot:latest username/cowrie-honeypot:latest

# Push
docker push username/cowrie-honeypot:latest
```

---

## Kubernetes Deployment Issues

### Pods stuck in "Pending"
```bash
# Check pod details
kubectl describe pod <pod-name>

# Common causes:
# 1. Image not available locally
kubectl set image deployment/cowrie-honeypot cowrie=<your-image>

# 2. No available nodes (check node status)
kubectl get nodes

# 3. Resource constraints
kubectl top nodes
kubectl describe node
```

### Pods in "CrashLoopBackOff"
```bash
# Check logs
kubectl logs <pod-name>
kubectl logs <pod-name> --previous  # Previous crash

# Common causes:
# - Container can't start
# - Health check failing
# - Entrypoint error

# Check last event
kubectl describe pod <pod-name> | grep -A 10 "Events"
```

### Pods in "ImagePullBackOff"
```bash
# Image is not available
# Solution 1: Build and load image locally
docker build -t cowrie-honeypot:latest .

# Solution 2: Push to registry
docker tag cowrie-honeypot:latest <registry>/cowrie-honeypot:latest
docker push <registry>/cowrie-honeypot:latest

# Update deployment
kubectl set image deployment/cowrie-honeypot cowrie=<registry>/cowrie-honeypot:latest

# Verify
kubectl get pods -w
```

### Pods in "Init:0/1" or "PodInitializing"
```bash
# Pod is initializing, wait a bit
kubectl get pods -w

# If stuck, check logs
kubectl logs <pod-name> --all-containers=true

# Restart if needed
kubectl delete pod <pod-name>
```

---

## Service & Networking Issues

### "Service has no endpoints"
```bash
# Check service
kubectl get svc cowrie-service

# Should list pod IPs under Endpoints
kubectl get endpoints cowrie-service

# If empty, pods might not be ready
kubectl get pods -l app=cowrie

# Check pod labels match selector
kubectl get pods --show-labels
```

### "Cannot connect to SSH port 30222"
```bash
# Verify service is exposed
kubectl get svc cowrie-service

# Check NodePort
kubectl get svc cowrie-service -o jsonpath='{.spec.ports[0].nodePort}'

# Verify pods are running
kubectl get pods -l app=cowrie

# Check if pods are serving on port 2222
kubectl port-forward <pod-name> 2222:2222 &
ssh -p 2222 root@localhost

# If network is restricted, check firewall
sudo ufw allow 30222
sudo firewall-cmd --add-port=30222/tcp --permanent
```

### "Connection refused" on SSH
```bash
# Pod may not be ready yet
kubectl get pods -l app=cowrie

# Check readiness probe
kubectl describe pod <pod-name> | grep Readiness

# Check container logs
kubectl logs <pod-name>

# Try via port-forward first
kubectl port-forward <pod-name> 2222:2222
ssh -p 2222 root@localhost
```

---

## Logging & Monitoring Issues

### "No logs available"
```bash
# Logs might not have been generated yet
sleep 30
kubectl logs <pod-name>

# Check if container is still running
kubectl get pods <pod-name> -o wide

# Check previous logs if container restarted
kubectl logs <pod-name> --previous

# Stream logs
kubectl logs -f <pod-name>

# All pods
kubectl logs -f -l app=cowrie
```

### "Metrics server not available" (kubectl top)
```bash
# Install metrics-server
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Wait for it to start
kubectl wait --for=condition=ready pod -n kube-system -l k8s-app=metrics-server --timeout=300s

# Verify
kubectl get deployment metrics-server -n kube-system
```

### "Events are not showing"
```bash
# Events are stored temporarily (by default 1 hour)
kubectl get events

# Check in specific namespace
kubectl get events -n default

# Watch events
kubectl get events -w

# Check event retention
kubectl get --raw /api/v1/nodes
```

---

## Scaling & Self-Healing Issues

### Scale command not working
```bash
# Check deployment exists
kubectl get deployment cowrie-honeypot

# Syntax
kubectl scale deployment cowrie-honeypot --replicas=5

# Alternative method
kubectl patch deployment cowrie-honeypot -p '{"spec":{"replicas":5}}'

# Edit directly
kubectl edit deployment cowrie-honeypot
# Change: spec.replicas: 5
```

### Pods not scaling down
```bash
# Check if pods are terminating
kubectl get pods -l app=cowrie --field-selector=status.phase=Terminating

# Force delete if stuck
kubectl delete pod <pod-name> --grace-period=0 --force

# Check disruption budget
kubectl get poddisruptionbudgets
```

### Self-healing not working (pod not restarting)
```bash
# Check restart policy
kubectl get pod <pod-name> -o jsonpath='{.spec.restartPolicy}'

# Should be "Always" (or unset, defaults to Always)
# If not, update deployment

# Check liveness probe
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].livenessProbe}'

# If missing, add to deployment.yaml and reapply
```

---

## ConfigMap Issues

### ConfigMap not being used
```bash
# Verify ConfigMap exists
kubectl get cm cowrie-config

# Check content
kubectl get cm cowrie-config -o yaml

# Verify pods are using it
kubectl get pods -l app=cowrie -o jsonpath='{.items[*].spec.containers[*].envFrom}'

# Should see configMapRef: name: cowrie-config

# If not, pods were created before ConfigMap
# Restart pods:
kubectl rollout restart deployment cowrie-honeypot
```

### ConfigMap values not updating
```bash
# ConfigMaps are cached by pods
# Restart pods to pick up changes
kubectl rollout restart deployment cowrie-honeypot

# Watch update
kubectl rollout status deployment/cowrie-honeypot -w

# Verify new values
kubectl exec <pod-name> -- env | grep -i cowrie
```

---

## Storage Issues (if using PersistentVolumes)

### "PersistentVolumeClaim stuck in Pending"
```bash
# Check PVC
kubectl get pvc

# Describe to see error
kubectl describe pvc <pvc-name>

# Common causes:
# 1. No PersistentVolume available
kubectl get pv

# 2. StorageClass missing
kubectl get storageclass

# Solution: Use emptyDir (already configured in deployment)
```

---

## Resource Limit Issues

### "Out of memory" (OOMKilled)
```bash
# Check limits in deployment
kubectl get deployment cowrie-honeypot -o jsonpath='{.spec.template.spec.containers[*].resources}'

# Increase limits
kubectl edit deployment cowrie-honeypot
# Increase spec.template.spec.containers[0].resources.limits.memory

# Reapply
kubectl apply -f deployment.yaml

# Check actual usage
kubectl top pods -l app=cowrie
```

### "CPU throttling"
```bash
# Check CPU limits
kubectl get deployment cowrie-honeypot -o jsonpath='{.spec.template.spec.containers[*].resources.limits.cpu}'

# Increase if needed
kubectl edit deployment cowrie-honeypot

# Current: 500m
# Increase to: 1000m or higher

# Reapply and restart
kubectl rollout restart deployment cowrie-honeypot
```

---

## Node Issues

### "Node not ready"
```bash
# Check node status
kubectl get nodes -o wide

# Describe node
kubectl describe node <node-name>

# Common issues:
# 1. Disk pressure
kubectl top nodes
df -h

# 2. Memory pressure
kubectl top nodes
free -h

# 3. Kubelet not running
sudo systemctl restart kubelet

# 4. Check kubelet logs
sudo journalctl -u kubelet -f
```

### "Cannot add nodes to cluster"
```bash
# On master, get join command
kubeadm token create --print-join-command

# On worker node, run the command provided

# If that doesn't work:
# 1. Check firewall
sudo ufw allow 6443
sudo ufw allow 10250

# 2. Verify network connectivity
ping <master-ip>

# 3. Check kubeadm logs
sudo journalctl -u kubelet
```

---

## Reset & Cleanup

### "Need to reset cluster"
```bash
# WARNING: Removes all data

# Delete all resources
kubectl delete all --all

# Reset cluster
sudo kubeadm reset

# Clean up directories
sudo rm -rf /var/lib/etcd
sudo rm -rf /var/lib/kubernetes
sudo rm -rf /etc/kubernetes

# Restart kubelet
sudo systemctl restart kubelet
```

### "Clear Docker images and containers"
```bash
# Stop all containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove honeypot image
docker rmi cowrie-honeypot:latest

# Or remove all images
docker rmi $(docker images -q)

# Clean up system
docker system prune -a
```

---

## Quick Diagnostics

### "Everything is broken" - Run this:
```bash
echo "=== CLUSTER ===" && kubectl cluster-info && \
echo "=== NODES ===" && kubectl get nodes && \
echo "=== PODS ===" && kubectl get pods -l app=cowrie && \
echo "=== SERVICES ===" && kubectl get svc cowrie-service && \
echo "=== CONFIGMAP ===" && kubectl get cm cowrie-config && \
echo "=== EVENTS ===" && kubectl get events --sort-by='.lastTimestamp' | tail -10
```

### "Pod keeps crashing" - Check this:
```bash
# Pod details
kubectl describe pod $(kubectl get pods -l app=cowrie -o jsonpath='{.items[0].metadata.name}')

# Recent logs
kubectl logs $(kubectl get pods -l app=cowrie -o jsonpath='{.items[0].metadata.name}') --tail=50

# Previous crash logs
kubectl logs $(kubectl get pods -l app=cowrie -o jsonpath='{.items[0].metadata.name}') --previous

# Watch for crashes
kubectl get pods -l app=cowrie -w
```

---

## FAQ

### Q: How long does deployment take?
A: ~2-3 minutes after cluster is ready.

### Q: Can I run this on a single node?
A: Yes, the master node can run pods (untainted in script).

### Q: What are the minimum requirements?
A: 2GB RAM, 2 CPU cores, 20GB disk space.

### Q: Can I use a different SSH port?
A: Yes, edit service.yaml and change nodePort: 30222.

### Q: How do I persist logs?
A: Add a PersistentVolume and PersistentVolumeClaim.

### Q: Can I scale beyond 10 replicas?
A: Yes, kubectl scale --replicas=100 (resource permitting).

### Q: How do I monitor resource usage?
A: kubectl top pods/nodes (requires metrics-server).

### Q: Can I use this in production?
A: Yes, with additional monitoring, logging, and security hardening.

---

**For additional help, check:**
- `kubectl describe` for detailed information
- `kubectl logs` for troubleshooting
- `kubectl get events` for system events
- Kubernetes docs: https://kubernetes.io/docs/tasks/debug-application-cluster/

