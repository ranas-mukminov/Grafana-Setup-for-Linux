#!/bin/bash
# scripts/install/arch-install.sh
# Grafana Stack Installation for Arch Linux
# Author: run-as-daemon.ru

set -e

echo "🚀 Grafana Stack Installation for Arch Linux"
echo "============================================"

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
sudo pacman -Syu --noconfirm

# Install dependencies
print_warning "Installing dependencies..."
sudo pacman -S --needed --noconfirm \
    base-devel \
    git \
    wget \
    curl \
    docker \
    docker-compose \
    podman \
    podman-compose

# Install Grafana
print_warning "Installing Grafana..."
sudo pacman -S --noconfirm grafana

# Install Prometheus
print_warning "Installing Prometheus..."
sudo pacman -S --noconfirm prometheus

# Install Node Exporter
print_warning "Installing Node Exporter..."
sudo pacman -S --noconfirm prometheus-node-exporter

# Enable and start services
print_warning "Enabling services..."
sudo systemctl enable --now grafana
sudo systemctl enable --now prometheus
sudo systemctl enable --now prometheus-node-exporter

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
sudo systemctl restart grafana

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
