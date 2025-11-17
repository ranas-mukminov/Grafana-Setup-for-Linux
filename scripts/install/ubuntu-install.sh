#!/bin/bash
# scripts/install/ubuntu-install.sh
# Grafana Stack Installation for Ubuntu 22.04/24.04
# Author: run-as-daemon.ru

set -e

echo "🚀 Grafana Stack Installation for Ubuntu"
echo "========================================"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Functions
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script must NOT be run as root"
   exit 1
fi

# Update system
print_warning "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

# Install dependencies
print_warning "Installing dependencies..."
sudo apt-get install -y \
    apt-transport-https \
    software-properties-common \
    wget \
    curl \
    gnupg2

# Install Grafana
print_warning "Installing Grafana..."
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana

# Install Prometheus
print_warning "Installing Prometheus..."
PROM_VERSION="2.48.0"
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
sudo cp prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/consoles /etc/prometheus/
sudo cp -r prometheus-${PROM_VERSION}.linux-amd64/console_libraries /etc/prometheus/

# Create Prometheus user
sudo useradd --no-create-home --shell /bin/false prometheus || true
sudo chown -R prometheus:prometheus /etc/prometheus /var/lib/prometheus

# Create Prometheus systemd service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file=/etc/prometheus/prometheus.yml \\
    --storage.tsdb.path=/var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Create basic Prometheus config
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOF

sudo chown -R prometheus:prometheus /etc/prometheus

# Install Node Exporter
print_warning "Installing Node Exporter..."
NODE_VERSION="1.7.0"
cd /tmp
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_VERSION}/node_exporter-${NODE_VERSION}.linux-amd64.tar.gz
tar xzf node_exporter-${NODE_VERSION}.linux-amd64.tar.gz
sudo cp node_exporter-${NODE_VERSION}.linux-amd64/node_exporter /usr/local/bin/

# Create Node Exporter systemd service
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
print_warning "Enabling and starting services..."
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl enable prometheus
sudo systemctl enable node_exporter
sudo systemctl start grafana-server
sudo systemctl start prometheus
sudo systemctl start node_exporter

# Configure firewall (if ufw is installed)
if command -v ufw &> /dev/null; then
    print_warning "Configuring firewall..."
    sudo ufw allow 3000/tcp  # Grafana
    sudo ufw allow 9090/tcp  # Prometheus
    sudo ufw allow 9100/tcp  # Node Exporter
fi

# Create configuration directories
print_warning "Creating configuration directories..."
sudo mkdir -p /etc/grafana/provisioning/{datasources,dashboards,alerting}
sudo mkdir -p /var/lib/grafana/dashboards

# Setup Prometheus datasource
print_warning "Configuring Prometheus datasource..."
cat <<EOF | sudo tee /etc/grafana/provisioning/datasources/prometheus.yml
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://localhost:9090
    isDefault: true
    editable: false
EOF

# Setup dashboard provider
cat <<EOF | sudo tee /etc/grafana/provisioning/dashboards/default.yml
apiVersion: 1

providers:
  - name: 'Default'
    orgId: 1
    folder: ''
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
EOF

# Restart Grafana
sudo systemctl restart grafana-server

# Cleanup
cd /tmp
rm -rf prometheus-${PROM_VERSION}.linux-amd64*
rm -rf node_exporter-${NODE_VERSION}.linux-amd64*

# Print success
print_success "Installation completed!"
echo ""
echo "============================================"
echo "📊 Access your services:"
echo "  Grafana:    http://localhost:3000"
echo "  Prometheus: http://localhost:9090"
echo ""
echo "🔑 Default Grafana credentials:"
echo "  Username: admin"
echo "  Password: admin"
echo ""
echo "⚠️  Please change the default password!"
echo "============================================"
