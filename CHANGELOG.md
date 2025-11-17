# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-11-16

### 🚀 Major Modernization

This is a complete rewrite and modernization of the project!

### Added

#### Documentation
- **README.md** - Comprehensive English documentation
- **README.ru.md** - Comprehensive Russian documentation with author services
- Installation guides for:
  - Ubuntu 22.04/24.04
  - Arch Linux
  - CentOS/RHEL 9
  - openSUSE Leap 15.5+
- **Security Best Practices** guide
- **High Availability Setup** guide
- **Docker Compose** documentation
- **Telegram Bot Integration** examples

#### Installation Scripts
- Modern installation script for Ubuntu 22.04/24.04
- Installation script for Arch Linux
- Installation script for CentOS/RHEL 9
- Installation script for openSUSE Leap
- All scripts include:
  - Automatic dependency installation
  - Service configuration
  - Firewall setup
  - Verification steps

#### Docker & Container Support
- Docker Compose for development
- Docker Compose for production with:
  - Loki for logs
  - Promtail for log collection
  - cAdvisor for container metrics
  - Alertmanager for alerts
  - Watchtower for auto-updates
- Environment variables configuration
- Kubernetes Helm values file

#### Automation
- **Makefile** with commands for:
  - Starting/stopping stack
  - Viewing logs
  - Backup/restore
  - Updates
  - Testing
- **Ansible playbook** for mass deployment
- **GitHub Actions** workflows for CI/CD

#### Monitoring Components
- Grafana provisioning for:
  - Prometheus datasource
  - Loki datasource
  - Dashboard providers
- Prometheus configuration with:
  - Multiple scrape configs
  - Alert rules support
  - Recording rules support
- Example system monitoring dashboard

#### Telegram Bot Integration
- **Prometheus exporter** for Telegram bots
- Middleware for aiogram 3.x
- Comprehensive metrics:
  - Message counters
  - Command tracking
  - Error monitoring
  - Performance metrics
  - API call tracking
- Full integration example
- Dashboard templates

#### Project Structure
- Organized directory structure:
  - `docs/` - Documentation
  - `scripts/` - Installation and maintenance scripts
  - `docker/` - Docker Compose files
  - `kubernetes/` - Kubernetes manifests
  - `ansible/` - Ansible playbooks
  - `grafana/` - Grafana configurations
  - `prometheus/` - Prometheus configurations
  - `exporters/` - Custom exporters
  - `examples/` - Usage examples

### Changed
- Updated from Ubuntu 16.04 to Ubuntu 22.04/24.04
- Replaced outdated installation methods with modern approaches
- Updated all component versions to latest stable:
  - Grafana 11.x
  - Prometheus 2.48.0
  - Node Exporter 1.7.0

### Improved
- Better error handling in scripts
- Comprehensive documentation with examples
- Multi-distribution support
- Security best practices
- High availability options
- Production-ready configurations

### Author Information
- Added comprehensive author information
- Contact details: email, Telegram, GitHub
- Professional services description
- Blog and portfolio links

## [1.0.0] - 2017-04-21

### Initial Release
- Basic installation steps for Ubuntu 16.04
- InfluxDB, Grafana, and Telegraf setup
- SNMP configuration examples
- Unraid integration script

---

## Migration from 1.x to 2.0

If you're upgrading from the old version:

1. **Backup your data**:
   ```bash
   sudo cp -r /var/lib/grafana /backup/
   sudo cp -r /var/lib/prometheus /backup/
   ```

2. **Use new installation methods**:
   - Docker Compose (recommended): `make start`
   - Native installation: `sudo bash scripts/install/ubuntu-install.sh`

3. **Import old dashboards** into new Grafana instance

4. **Update Prometheus configs** to match new format

For help with migration, contact: [@runas_daemon](https://t.me/runas_daemon)

---

**Note**: Version 1.x was focused on Ubuntu 16.04. Version 2.0 is a complete rewrite supporting modern Linux distributions with Docker, Kubernetes, and comprehensive automation.
