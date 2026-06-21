# Quick Reference Cheat Sheet

## 🚀 FASTEST PATH (Copy-Paste)

### One-Command Full Setup (Run sequentially)
```bash
# 1. Setup Kubernetes
chmod +x *.sh && ./01-setup-kubernetes.sh

# 2. Build Docker image
./02-build-docker.sh

# 3. Deploy to Kubernetes
./03-deploy-kubernetes.sh

# 4. Test deployment
./04-test-deployment.sh

# 5. Demo scaling
./05-demo-scaling.sh
```

---

## 📋 ESSENTIAL COMMANDS ONLY

### Check Everything
```bash
kubectl get all -l app=cowrie
kubectl get pods -o wide
kubectl logs -f -l app=cowrie --tail=50
```

### Get Access Info
```bash
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "SSH: ssh -p 30222 root@$NODE_IP"
```

### Scale Deployment
```bash
kubectl scale deployment cowrie-honeypot --replicas=5
kubectl get pods -w
```

### Delete Pod (Self-healing demo)
```bash
kubectl delete pod $(kubectl get pods -l app=cowrie -o jsonpath='{.items[0].metadata.name}')
kubectl get pods -w
```

### View Logs
```bash
kubectl logs -l app=cowrie --tail=100
kubectl logs <pod-name> -f
```

### Cleanup
```bash
kubectl delete deployment,svc,configmap -l app=cowrie
```

---

## 🔧 DOCKER COMMANDS

```bash
# Build
docker build -t cowrie-honeypot:latest .

# Tag
docker tag cowrie-honeypot:latest localhost:5000/cowrie-honeypot:latest

# Push
docker push localhost:5000/cowrie-honeypot:latest

# Test run
docker run -it --rm -p 2222:2222 cowrie-honeypot:latest
```

---

## 📊 MONITORING

```bash
# Resource usage
kubectl top pods -l app=cowrie
kubectl top nodes

# Event monitoring
kubectl get events -w

# Pod status details
kubectl describe pod <pod-name>

# Detailed logs with context
kubectl logs <pod-name> --previous  # Previous crashed container
```

---

## 🐛 DEBUGGING

```bash
# Pod issues
kubectl describe deployment cowrie-honeypot
kubectl logs <pod-name> --all-containers=true

# Service issues
kubectl get svc -o wide
kubectl describe svc cowrie-service

# Network connectivity
kubectl run debug --image=busybox -it --rm -- sh
  # Inside pod:
  wget -O- http://cowrie-service:2222

# SSH test
timeout 5 ssh -vv -p 30222 root@<node-ip>
```

---

## 🔄 SCALING WORKFLOW

```bash
# Check current
kubectl get deployment cowrie-honeypot

# Scale up
kubectl scale deployment cowrie-honeypot --replicas=10

# Check progress
kubectl get pods -l app=cowrie -w

# Scale down
kubectl scale deployment cowrie-honeypot --replicas=3
```

---

## 🛡️ SELF-HEALING DEMO

```bash
# Delete random pod
POD=$(kubectl get pods -l app=cowrie -o jsonpath='{.items[0].metadata.name}')
kubectl delete pod $POD

# Watch it recreate
kubectl get pods -l app=cowrie -w

# Kill process in container
kubectl exec <pod-name> -- kill -9 1

# Pod restarts automatically
```

---

## 📝 LOG AGGREGATION

```bash
# All pods, last 50 lines
kubectl logs -l app=cowrie --tail=50

# Stream all pods
kubectl logs -f -l app=cowrie --all-containers=true

# Export to file
kubectl logs -l app=cowrie > logs.txt

# With timestamp
kubectl logs -l app=cowrie --timestamps=true
```

---

## 🗑️ CLEANUP

```bash
# Delete honeypot only
kubectl delete -f deployment.yaml -f service.yaml -f configmap.yaml

# Delete entire namespace
kubectl delete namespace honeypot

# Reset cluster (⚠️ WARNING - destructive)
sudo kubeadm reset

# Remove Docker image
docker rmi cowrie-honeypot:latest
```

---

## 🔌 PORT MAPPINGS

| Service | Internal | NodePort | Purpose |
|---------|----------|----------|---------|
| SSH | 2222 | 30222 | Honeypot SSH |
| API | 5000 | 30500 | Cowrie API |

---

## ✅ VERIFICATION CHECKLIST

```bash
[ ] kubectl cluster-info              # Cluster running
[ ] kubectl get nodes                 # Nodes ready
[ ] kubectl get pods -l app=cowrie    # Pods running
[ ] kubectl get svc cowrie-service    # Service active
[ ] kubectl logs -l app=cowrie        # No errors in logs
[ ] ssh -p 30222 root@NODE_IP         # SSH accessible
```

---

## 📱 USEFUL ALIASES (Add to ~/.bashrc)

```bash
alias k='kubectl'
alias kgp='kubectl get pods -l app=cowrie -o wide'
alias klogs='kubectl logs -f -l app=cowrie --tail=50'
alias kdesc='kubectl describe pod'
alias kscale='kubectl scale deployment cowrie-honeypot --replicas'
alias kwatch='kubectl get pods -l app=cowrie -w'
```

---

## 🆘 COMMON ISSUES & FIXES

| Issue | Fix |
|-------|-----|
| Pods stuck in Pending | Check: `kubectl describe pod <pod>` |
| ImagePullBackOff | Build/push image: `./02-build-docker.sh` |
| CrashLoopBackOff | Check logs: `kubectl logs <pod>` |
| Service unreachable | Verify: `kubectl get svc -o wide` |
| SSH not responding | Check port: `nc -zv NODE_IP 30222` |

---

## 🎯 ONE-LINER COMMANDS

```bash
# Get node IP
kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}'

# Get all pods
kubectl get pods -l app=cowrie --no-headers | awk '{print $1}'

# Delete all honeypot pods
kubectl delete pods -l app=cowrie

# Count running pods
kubectl get pods -l app=cowrie --field-selector=status.phase=Running --no-headers | wc -l

# Watch deployment rollout
kubectl rollout status deployment/cowrie-honeypot -w

# Stream logs from all pods
kubectl logs -f -l app=cowrie --all-containers=true --max-log-requests=10

# Get high resource usage pods
kubectl top pods -l app=cowrie --sort-by=memory
```

---

## 🔐 SECURITY QUICK CHECK

```bash
# Check security context
kubectl get pod <pod-name> -o jsonpath='{.spec.securityContext}'

# Check resource limits
kubectl get pods -l app=cowrie -o jsonpath='{.items[*].spec.containers[*].resources}'

# Check RBAC
kubectl get rolebindings
kubectl get clusterrolebindings

# Check pod security policy (if enabled)
kubectl get psp
```

---

**TL;DR**: Run scripts 1-5 in order. SSH to honeypot on 30222. Done!
