# 🍯 Distributed SSH Honeypot on Kubernetes

> A production-grade SSH honeypot system built with **Cowrie**, **Docker**, and **Kubernetes** — designed to capture, log, and analyze real-world brute-force attacks at scale.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Enabled-2496ED.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Supported-326CE5.svg)](https://kubernetes.io/)
[![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420.svg)](https://ubuntu.com/)

---

## 📌 What This Project Does

This system deploys multiple Cowrie SSH honeypot instances across a Kubernetes cluster. Attackers who attempt SSH brute-force connections are silently logged — their credentials, commands, and file transfers are all captured for analysis.

**Built for**: Cybersecurity researchers, threat analysts, SOC teams, and DevSecOps practitioners.

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| Honeypot Engine | [Cowrie](https://github.com/cowrie/cowrie) (medium-interaction SSH emulator) |
| Containerization | Docker (Ubuntu 22.04 base) |
| Orchestration | Kubernetes (kubeadm / Minikube) |
| Networking | NodePort Service, Pod Anti-Affinity |
| Storage | Persistent Volume Claims (PVC) |
| Config Management | Kubernetes ConfigMaps |
| Logging | JSON-structured logs, session recordings |

---

## ✨ Key Features

- **Distributed Deployment** — 3+ honeypot replicas spread across nodes via pod anti-affinity rules
- **Self-Healing** — Kubernetes automatically restarts failed pods with zero manual intervention
- **Horizontal Scaling** — Scale from 1 to 100+ instances with a single `kubectl scale` command
- **Full Session Capture** — Logs attacker credentials, shell commands, and file downloads in JSON
- **Health Monitoring** — Liveness and readiness probes ensure continuous availability
- **Resource Controlled** — CPU/memory limits prevent any single pod from exhausting cluster resources

---

## 🏗️ Architecture

```
                    [ Internet / Attackers ]
                             │
                    [ NodePort :30222 ]
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
     ┌────▼────┐        ┌────▼────┐        ┌────▼────┐
     │  Pod 1  │        │  Pod 2  │        │  Pod 3  │
     │ Cowrie  │        │ Cowrie  │        │ Cowrie  │
     │  :2222  │        │  :2222  │        │  :2222  │
     └────┬────┘        └────┬────┘        └────┬────┘
          └─────────────────┬─────────────────────┘
                            │
               [ Persistent Volume (PVC) ]
               ├── cowrie.json  (structured logs)
               ├── cowrie.log   (plaintext logs)
               └── session TTY recordings
```

---

## ⚡ Quick Start

### Option 1 — Docker Compose (5 minutes)
```bash
git clone https://github.com/yourusername/honeypot-project.git
cd honeypot-project

./02-build-docker.sh
docker-compose up -d

# Connect to a honeypot (password: admin)
ssh -p 2222 admin@localhost
```

### Option 2 — Kubernetes / Minikube (10 minutes)
```bash
minikube start --cpus=4 --memory=4096

./01-setup-kubernetes.sh
./02-build-docker.sh
./03-deploy-kubernetes.sh
./04-test-deployment.sh
```

### Option 3 — Full Production Cluster (20–30 minutes)
```bash
./01-setup-kubernetes.sh    # Initialize cluster
./02-build-docker.sh        # Build & tag image
./03-deploy-kubernetes.sh   # Deploy honeypots
./04-test-deployment.sh     # Validate
./05-demo-scaling.sh        # Demonstrate scaling
./06-validate-installation.sh
```

---

## 📊 Log Analysis

Logs are written as structured JSON, making them easy to parse, forward to SIEM tools, or analyze with `jq`.

```bash
# Failed login attempts
cat cowrie.json | jq 'select(.eventid=="cowrie.login.failed") | {src_ip, username, password}'

# Commands executed by attackers
cat cowrie.json | jq 'select(.eventid=="cowrie.command.input") | .input'

# File downloads initiated
cat cowrie.json | jq 'select(.eventid=="cowrie.sftp.get")'
```

**Sample log entry:**
```json
{
  "eventid": "cowrie.login.failed",
  "timestamp": "2024-06-21T12:30:45.123Z",
  "src_ip": "192.168.1.100",
  "username": "admin",
  "password": "password123",
  "session": "abc123def456"
}
```

---

## 📁 Project Structure

```
honeypot-project/
├── Dockerfile                  # Cowrie container image
├── docker-compose.yml          # Local multi-instance setup
├── configmap.yaml              # Kubernetes environment config
├── deployment.yaml             # K8s Deployment (3 replicas, resource limits)
├── service.yaml                # NodePort Service on :30222
├── 01-setup-kubernetes.sh      # Cluster initialization
├── 02-build-docker.sh          # Image build
├── 03-deploy-kubernetes.sh     # Deploy to K8s
├── 04-test-deployment.sh       # Smoke tests
├── 05-demo-scaling.sh          # Scaling demo
├── 06-validate-installation.sh # Final validation
└── cowrie/
    ├── etc/cowrie.cfg          # Honeypot config
    ├── etc/userdb.txt          # Fake credential database
    └── honeyfs/                # Emulated Linux filesystem
```

---

## ⚙️ Configuration

All settings are managed via `configmap.yaml` — no image rebuild needed:

```yaml
COWRIE_SSH_PORT: "2222"
COWRIE_HOSTNAME: "ubuntu-server"
COWRIE_LOG_LEVEL: "INFO"
```

Pod resource limits are defined in `deployment.yaml`:
```yaml
resources:
  limits:
    cpu: "500m"
    memory: "512Mi"
  requests:
    cpu: "100m"
    memory: "256Mi"
```

---

## 📈 Scaling

```bash
# Scale to 10 honeypot instances
kubectl scale deployment cowrie-honeypot --replicas=10

# Watch pods spin up
kubectl get pods -w

# Enable autoscaling based on CPU
kubectl autoscale deployment cowrie-honeypot --min=3 --max=20 --cpu-percent=80
```

---

## 🔧 Prerequisites

| Requirement | Docker Compose | Kubernetes |
|---|---|---|
| OS | Ubuntu 20.04+ | Ubuntu 20.04+ |
| RAM | 2 GB | 4 GB+ |
| Docker | ≥ 20.10 | ≥ 20.10 |
| kubectl | — | ≥ 1.25 |
| Minikube | — | ≥ 1.28 (local testing) |

---

## 🛠️ Troubleshooting

| Issue | Fix |
|---|---|
| Pods in `CrashLoopBackOff` | `kubectl logs <pod>` → check image pull or config errors |
| Cannot SSH to honeypot | Verify NodePort with `kubectl get svc cowrie-service` |
| OOM errors | Increase `memory.limits` in `deployment.yaml` |
| Image not found | Re-run `./02-build-docker.sh` and confirm `docker images` |

---

## 🗺️ Roadmap

- [ ] Grafana + Prometheus monitoring dashboard
- [ ] ELK stack integration for centralized log analysis
- [ ] Helm chart for one-command deployment
- [ ] Terraform support for multi-cloud provisioning
- [ ] ML-based attack pattern detection

---

## 📄 License

This project is licensed under the **MIT License**.
Cowrie is licensed under **GPL v2** — see [cowrie/LICENSE.rst](cowrie/LICENSE.rst).

---

## 🙏 Acknowledgments

- [Cowrie](https://github.com/cowrie/cowrie) — The SSH honeypot engine powering this system
- [Kubernetes](https://kubernetes.io/) & [Docker](https://www.docker.com/) — Orchestration and containerization

---

*Built by [Rachit Rachit](https://github.com/yourusername) · Contributions welcome via pull request*
