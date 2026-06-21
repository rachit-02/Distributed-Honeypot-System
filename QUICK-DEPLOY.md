# Quick Deployment Without Full Kubernetes Setup

Since full Kubernetes cluster setup is complex on this system, here are **working alternatives**:

---

## Option 1: Docker Compose (FASTEST - 5 minutes)

Run the honeypot with Docker Compose instead:

```bash
cd /home/rachitrachit/honeypot-project

# Create docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  cowrie-1:
    image: cowrie-honeypot:latest
    ports:
      - "2222:2222"
    environment:
      - COWRIE_SSH_PORT=2222
      - COWRIE_HOSTNAME=honeypot-1
    volumes:
      - logs1:/cowrie/var/log/cowrie
    restart: always

  cowrie-2:
    image: cowrie-honeypot:latest
    ports:
      - "2223:2222"
    environment:
      - COWRIE_SSH_PORT=2222
      - COWRIE_HOSTNAME=honeypot-2
    volumes:
      - logs2:/cowrie/var/log/cowrie
    restart: always

  cowrie-3:
    image: cowrie-honeypot:latest
    ports:
      - "2224:2222"
    environment:
      - COWRIE_SSH_PORT=2222
      - COWRIE_HOSTNAME=honeypot-3
    volumes:
      - logs3:/cowrie/var/log/cowrie
    restart: always

volumes:
  logs1:
  logs2:
  logs3:
EOF

# Start the honeypots
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

### Access the honeypots:
```bash
# Connect to honeypot 1
ssh -p 2222 root@localhost

# Connect to honeypot 2
ssh -p 2223 root@localhost

# Connect to honeypot 3
ssh -p 2224 root@localhost
```

### Scale them:
```bash
# Stop all
docker-compose down

# Edit the yml file above and copy cowrie-3 to cowrie-4, etc.
# Then restart
docker-compose up -d
```

---

## Option 2: Using Minikube (10 minutes)

If you want a lightweight Kubernetes:

```bash
# Install minikube
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Start minikube
minikube start --driver=docker

# Set docker to use minikube's docker
eval $(minikube docker-env)

# Rebuild the image
docker build -t cowrie-honeypot:latest .

# Then use the original deployment scripts
./03-deploy-kubernetes.sh
./04-test-deployment.sh
```

---

## Option 3: Using Kind (Kubernetes in Docker - 10 minutes)

```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create a cluster
kind create cluster --name honeypot

# Load the image
kind load docker-image cowrie-honeypot:latest --name honeypot

# Then deploy
./03-deploy-kubernetes.sh
./04-test-deployment.sh
```

---

## **RECOMMENDED: Option 1 (Docker Compose)**

Fastest and simplest! Run:

```bash
cd /home/rachitrachit/honeypot-project
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  cowrie-1:
    image: cowrie-honeypot:latest
    ports:
      - "2222:2222"
    restart: always
  cowrie-2:
    image: cowrie-honeypot:latest
    ports:
      - "2223:2222"
    restart: always
  cowrie-3:
    image: cowrie-honeypot:latest
    ports:
      - "2224:2222"
    restart: always
EOF

docker-compose up -d
docker-compose ps
```

**Test it:**
```bash
ssh -p 2222 root@localhost
```

**That's it!** You have 3 running honeypots! ✅

