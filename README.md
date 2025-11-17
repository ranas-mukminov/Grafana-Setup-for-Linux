# 🎯 Grafana Setup for Linux - Complete Guide

<div align="center">

[![Grafana](https://img.shields.io/badge/Grafana-11.x-orange.svg)](https://grafana.com/)
[![Prometheus](https://img.shields.io/badge/Prometheus-2.x-red.svg)](https://prometheus.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5.svg)](https://kubernetes.io/)

**Modern guide for installing and configuring Grafana on Linux**

**English** | [Русский](README.ru.md)

</div>

---

## 👨‍💻 About the Author

Hi! I'm a DevOps engineer and system administrator with experience in complex infrastructures.

**My Services:**
- 🔧 Monitoring system setup (Grafana, Prometheus, Loki)
- 🐳 Application containerization (Docker, Podman, Kubernetes)
- 🤖 Telegram bot development with monitoring integration
- 🚀 DevOps automation and CI/CD pipelines
- 📊 Metrics collection and visualization systems
- 🔐 Security and backup configuration

### 📱 Contact Me

- 🌐 **Website:** [run-as-daemon.ru](https://run-as-daemon.ru)
- 🔗 **GitHub:** [@ranas-mukminov](https://github.com/ranas-mukminov)
- 📧 **Email:** 79997679000@mail.ru
- 💬 **Telegram:** [@runas_daemon](https://t.me/runas_daemon)

### 💼 Project Portfolio

On my [blog](https://run-as-daemon.ru) you'll find:
- Monitoring setup case studies
- Unique experience managing servers at 10,000 meters altitude ✈️
- Infrastructure automation solutions
- Telegram bot integration with monitoring systems

---

## 🎯 What's Inside This Repository?

Complete toolset and documentation for deploying **production-ready** Grafana-based monitoring systems:

### ✨ Features

- ⚡ **Quick Start** - installation in 5 minutes
- 🐳 **Docker/Podman ready** - fully containerized solutions
- ☸️ **Kubernetes manifests** - for cloud deployments
- 🔄 **Automation** - Ansible playbooks for mass deployment
- 📊 **Ready-made dashboards** - for system monitoring and Telegram bots
- 🔐 **Production security** - SSL, authentication, backups
- 🎨 **Dark theme** - ready customization for your brand

---

## 🚀 Quick Start

### Option 1: Docker Compose (recommended)

```bash
# Clone repository
git clone https://github.com/ranas-mukminov/Grafana-Setup-for-Linux.git
cd Grafana-Setup-for-Linux

# Copy and configure variables
cp docker/.env.example docker/.env
nano docker/.env  # Set your passwords

# Start monitoring stack
make start

# Check status
make status

# Open Grafana
# http://localhost:3000
# Login: admin
# Password: see .env
```

### Option 2: Native Installation

**Ubuntu 22.04/24.04:**
```bash
sudo bash scripts/install/ubuntu-install.sh
```

**Arch Linux:**
```bash
sudo bash scripts/install/arch-install.sh
```

**CentOS/RHEL 9:**
```bash
sudo bash scripts/install/centos-install.sh
```

**openSUSE Leap:**
```bash
sudo bash scripts/install/suse-install.sh
```

### Option 3: Kubernetes (Helm)

```bash
# Add Helm repository
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install with our settings
helm install grafana grafana/grafana \
  -f kubernetes/helm/values.yaml \
  --namespace monitoring \
  --create-namespace
```

---

## 📚 Supported Distributions

| Distribution | Versions | Status | Installation Script |
|-------------|---------|--------|---------------------|
| Ubuntu | 22.04, 24.04 | ✅ Tested | `scripts/install/ubuntu-install.sh` |
| Debian | 11, 12 | ✅ Tested | `scripts/install/ubuntu-install.sh` |
| Arch Linux | Rolling | ✅ Tested | `scripts/install/arch-install.sh` |
| CentOS | 9 Stream | ✅ Tested | `scripts/install/centos-install.sh` |
| RHEL | 9.x | ✅ Tested | `scripts/install/centos-install.sh` |
| Rocky Linux | 9.x | ✅ Tested | `scripts/install/centos-install.sh` |
| openSUSE | Leap 15.5+ | ✅ Tested | `scripts/install/suse-install.sh` |

---

## 🎨 Ready-Made Dashboards

### 1. System Monitoring

- CPU, Memory, Disk, Network
- Processes and services
- Temperature and uptime

### 2. Docker Containers

- Container status
- Resource usage
- Real-time logs

### 3. Kubernetes Cluster

- Pod and node status
- Resource quotas
- Namespace metrics

### 4. Telegram Bots (for developers)

- User count
- Processed messages
- Errors and performance
- API call statistics

---

## 🔧 Solution Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Grafana Frontend                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │  Dashboards │  │   Alerts    │  │    Users    │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
└───────────────────────┬─────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌─────────────┐ ┌──────────────┐
│  Prometheus  │ │    Loki     │ │   InfluxDB   │
│  (Metrics)   │ │   (Logs)    │ │  (TimeSeries)│
└──────┬───────┘ └──────┬──────┘ └──────┬───────┘
       │                │               │
       └────────────────┼───────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌──────────────┐ ┌─────────────┐ ┌──────────────┐
│ Node Export  │ │  Promtail   │ │   Telegraf   │
│    (OS)      │ │   (Logs)    │ │    (SNMP)    │
└──────────────┘ └─────────────┘ └──────────────┘
```

---

## 🛠️ Advanced Features

### High Availability (HA)

```bash
# Deploy HA cluster
ansible-playbook ansible/playbook.yml -i ansible/inventory/production
```

### Telegram Bot Integration

```python
# Example metrics exporter for your bot
from prometheus_client import start_http_server, Counter, Gauge

bot_messages = Counter('bot_messages_total', 'Total messages')
active_users = Gauge('bot_active_users', 'Active users')

# Start exporter on port 8000
start_http_server(8000)
```

### Automatic Backup

```bash
# Setup daily backup at 2:00 AM
sudo crontab -e
0 2 * * * /opt/grafana-backup/backup.sh
```

---

## 📖 Full Documentation

- 📘 [Ubuntu Installation](docs/installation/ubuntu-22.04-24.04.md)
- 📗 [Arch Linux Installation](docs/installation/arch-linux.md)
- 📙 [CentOS/RHEL Installation](docs/installation/centos-rhel-9.md)
- 📕 [openSUSE Installation](docs/installation/opensuse-leap.md)
- 🐳 [Docker Compose setup](docs/docker/docker-compose.md)
- ☸️ [Kubernetes Helm setup](docs/kubernetes/helm-installation.md)
- 🔐 [Security Best Practices](docs/advanced/security.md)
- 🔄 [High Availability Setup](docs/advanced/ha-setup.md)

---

## 💡 Useful Commands

```bash
# View all available commands
make help

# Start stack
make start

# Stop
make stop

# Restart
make restart

# View logs
make logs

# Backup data
make backup

# Restore from backup
make restore

# Update to latest version
make update

# Tests
make test
```

---

## 🤝 Need Help?

### 💼 Professional Services

I offer the following monitoring system installation and configuration services:

#### 📦 Basic Package
- Grafana + Prometheus installation
- Basic dashboard setup
- Documentation
- **Price:** negotiable

#### 🚀 Advanced Package
- Full LGTM stack (Loki + Grafana + Tempo + Mimir)
- Custom dashboards for your needs
- Integration with existing infrastructure
- Alerting configuration
- Team training
- **Price:** negotiable

#### 🏢 Enterprise Package
- High Availability cluster
- Multi-tenancy setup
- AD/LDAP integration
- Custom plugins and exporters
- SLA support
- **Price:** negotiable

### 📞 Consultations

- **One-time consultation (1 hour):** negotiable
- **Technical support (monthly):** negotiable
- **Custom solution development:** individual

### 🎓 Training

I conduct individual and corporate training on:
- Grafana for beginners
- Prometheus and metrics systems
- DevOps monitoring best practices
- Telegram bots with monitoring

**Contact:** [run-as-daemon.ru](https://run-as-daemon.ru)

---

## 🤝 Contributing

Pull Requests are welcome! Before submitting:

1. Create an issue describing the problem/improvement
2. Fork the repository
3. Create a feature branch
4. Test your changes
5. Submit a PR

---

## 📝 License

MIT License - see [LICENSE](LICENSE)

---

## ⭐ Acknowledgments

If this project helped you - give it a star! ⭐

Follow my [blog](https://run-as-daemon.ru) for new case studies and tutorials.

---

<div align="center">

**Made with ❤️ by [Ranas Mukminov](https://run-as-daemon.ru)**

[⬆ Back to top](#-grafana-setup-for-linux---complete-guide)

</div>
