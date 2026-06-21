# 🚀 QUICK START GUIDE

**Estimated Time: 20-30 minutes**

---

## ⏱️ 5-Minute Overview

```
What: Distributed SSH honeypot on Kubernetes
Where: Your server/VM
Cost: Free (open source)
Time: 20 min setup + 5 min demo
```

---

## 📋 Prerequisites (Check These First)

```bash
# Ubuntu system
uname -a  # Should show Linux

# Have sudo access
sudo whoami

# Internet connection
ping 8.8.8.8

# At least 2GB RAM
free -h

# At least 20GB disk
df -h
```

---

## 🎬 Step 1: Setup Kubernetes (10-15 minutes)

```bash
cd /home/rachitrachit/honeypot-project

# Make executable (done, but just in case)
chmod +x *.sh

# Run setup script
./01-setup-kubernetes.sh
```

**What it does**:
- Installs Docker
- Installs Kubernetes tools
- Creates cluster
- Installs networking

**Expected output**:
```
[+] ===== SETUP COMPLETE =====
[+] Cluster Status:
[+] Node Status:
[+] Pod Status (kube-system):
```

**If it fails**:
1. Check internet: `ping google.com`
2. Check sudo: `sudo whoami`
3. See TROUBLESHOOTING.md

---

## 🐳 Step 2: Build Docker Image (2-3 minutes)

```bash
./02-build-docker.sh
```

**What it does**:
- Builds Cowrie container
- Tests image
- Offers to push to registry

**Expected output**:
```
[+] Image built successfully
[+] Image tagged
REPOSITORY          TAG     IMAGE ID
cowrie-honeypot     latest  xxxxxxxxx
```

**When asked "Push to registry?"**: Press `n` (for now)

---

## 📦 Step 3: Deploy to Kubernetes (1-2 minutes)

```bash
./03-deploy-kubernetes.sh
```

**What it does**:
- Creates ConfigMap
- Creates Deployment (3 pods)
- Creates Service (SSH on 30222)
- Waits for pods to start

**Expected output**:
```
[+] ===== DEPLOYMENT COMPLETE =====
[+] Pods:
NAME                              READY   STATUS    RESTARTS
cowrie-honeypot-xxxxx            1/1     Running   0
cowrie-honeypot-xxxxx            1/1     Running   0
cowrie-honeypot-xxxxx            1/1     Running   0

[+] SSH Access:
Address: 192.168.1.100
Port: 30222
Command: ssh -p 30222 root@192.168.1.100
```

**If pods don't start**:
```bash
# Check what's wrong
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

---

## ✅ Step 4: Validate Deployment (1 minute)

```bash
./04-test-deployment.sh
```

**What it does**:
- Tests cluster health
- Verifies all pods running
- Tests SSH connectivity
- Validates logs

**Expected output**:
```
TEST 1: Cluster Health ✓
TEST 2: Deployment Status ✓
TEST 3: Pod Status ✓
All replicas are ready (3/3)
TEST 4: Service Status ✓
[+] SSH port is accessible
[+] ===== TEST SUMMARY =====
```

---

## 🎯 Step 5: Try It Out! (Demo)

### Test SSH Access

```bash
# Get node IP
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# Connect to honeypot
ssh -o StrictHostKeyChecking=no -p 30222 root@$NODE_IP

# Try any password (honeypot accepts all)
# Try commands: ls, pwd, whoami, cat /etc/passwd
# Type 'exit' to disconnect
```

### View Honeypot Logs

```bash
# See what was captured
kubectl logs -l app=cowrie --tail=50

# Watch logs in real-time
kubectl logs -f -l app=cowrie
```

---

## 🎪 Step 6: Demo Scaling (5-10 minutes)

```bash
./05-demo-scaling.sh
```

**What it does**:
1. Scales up to 5 pods
2. Shows all running
3. Scales back to 3
4. Deletes a pod (watch it auto-recreate)
5. Shows resource usage

**Expected output**:
```
[*] DEMO 1: Scaling Up Replicas
[*] Scaling to 5 replicas...
[*] Watching pod creation...
Pods ready: 5/5 ✓

[*] DEMO 3: Self-Healing
[*] Deleting pod: cowrie-honeypot-xxxxx
[*] Waiting for new pod to be created...
New pod status:
[+] Self-healing complete! ✓
```

---

## ✨ BOOM! You're Done! 🎉

All 6 steps complete = Working honeypot cluster!

---

## 📊 What You Now Have

```
✓ Kubernetes cluster (3 nodes: 1 master, 2 workers conceptually)
✓ 3 Cowrie SSH honeypots running
✓ Load-balanced SSH service on port 30222
✓ Self-healing pods (auto-restart if crash)
✓ Scalable deployment (can add more pods)
✓ Centralized configuration (via ConfigMap)
✓ Complete logs collection
```

---

## 🎓 Key Commands to Remember

```bash
# See all pods
kubectl get pods -l app=cowrie

# See logs
kubectl logs -l app=cowrie --tail=50

# Scale to 10 pods
kubectl scale deployment cowrie-honeypot --replicas=10

# Delete honeypot (if needed)
kubectl delete -f deployment.yaml -f service.yaml -f configmap.yaml

# Full status
kubectl get all -l app=cowrie
```

---

## 🆘 If Something Goes Wrong

**Problem**: Pods stuck in "Pending"
```bash
kubectl describe pod <pod-name>
```

**Problem**: Cannot SSH
```bash
# Check service
kubectl get svc cowrie-service

# Check pods
kubectl get pods -l app=cowrie
```

**Problem**: Everything broken
```bash
# Full diagnostics
./06-validate-installation.sh

# See TROUBLESHOOTING.md for detailed help
```

---

## 📚 Next Steps

1. **Read** CHEATSHEET.md (for future reference)
2. **Customize** deployment.yaml (change replicas, resources, etc.)
3. **Monitor** with `kubectl top pods` (requires metrics-server)
4. **Secure** with NetworkPolicies
5. **Persist** logs with PersistentVolumes
6. **Analyze** attacks with ELK stack

---

## 📁 File Overview

```
README.md              ← Complete reference
CHEATSHEET.md         ← Copy-paste commands
TROUBLESHOOTING.md    ← Problem solving
IMPLEMENTATION.md     ← Technical details
FILE-INDEX.md         ← This overview

01-setup-kubernetes   ← Infrastructure
02-build-docker       ← Container
03-deploy-kubernetes  ← Deployment
04-test-deployment    ← Validation
05-demo-scaling       ← Demo
06-validate           ← Verification

Dockerfile            ← Image definition
*.yaml               ← Kubernetes configs
```

---

## 💡 Pro Tips

1. **Keep terminal open**: Scripts take time, don't interrupt
2. **Watch pods**: `kubectl get pods -l app=cowrie -w`
3. **Stream logs**: `kubectl logs -f -l app=cowrie`
4. **Check resources**: `kubectl top pods` (if available)
5. **Iterate quickly**: Edit YAML and `kubectl apply -f`

---

## ⏱️ Timing Reference

| Step | Time | Action |
|------|------|--------|
| 1 | 10-15 min | ./01-setup-kubernetes.sh |
| 2 | 2-3 min | ./02-build-docker.sh |
| 3 | 1-2 min | ./03-deploy-kubernetes.sh |
| 4 | 1 min | ./04-test-deployment.sh |
| 5 | 5-10 min | ./05-demo-scaling.sh |
| Total | **20-30 min** | **Complete system ready!** |

---

## 🎯 Success Criteria

After completion, you should be able to:

```bash
# 1. See 3 running pods
kubectl get pods -l app=cowrie
# Expected: 3 Running

# 2. SSH to honeypot
ssh -p 30222 root@<node-ip>
# Expected: Connected

# 3. See logs
kubectl logs -l app=cowrie
# Expected: Logs with no errors

# 4. Scale easily
kubectl scale deployment cowrie-honeypot --replicas=5
# Expected: 5 pods running

# 5. Self-healing works
kubectl delete pod <pod-name>
# Expected: New pod created automatically
```

---

## 🚨 Emergency Reset

If something's broken:

```bash
# Kill everything
kubectl delete all --all

# Reset cluster
sudo kubeadm reset

# Start over from step 1
./01-setup-kubernetes.sh
```

---

## 📞 Getting Help

1. **Check logs**: `kubectl logs <pod-name>`
2. **Check status**: `kubectl describe pod <pod-name>`
3. **Check events**: `kubectl get events`
4. **Read**: TROUBLESHOOTING.md
5. **Run validator**: `./06-validate-installation.sh`

---

## 🎓 What You Learned

After completing this, you understand:
- ✓ Docker containerization
- ✓ Kubernetes cluster setup
- ✓ Pod deployment & management
- ✓ Service networking
- ✓ Horizontal scaling
- ✓ Self-healing & resilience
- ✓ Log aggregation
- ✓ Honeypot operations

---

## 🏁 Ready to Start?

```bash
cd /home/rachitrachit/honeypot-project

# Start now!
./01-setup-kubernetes.sh
```

**Enjoy! 🚀**

---

**Questions?** Check README.md, CHEATSHEET.md, or TROUBLESHOOTING.md

**Everything ready?** Start with `./01-setup-kubernetes.sh`
