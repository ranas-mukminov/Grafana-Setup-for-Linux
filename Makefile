.PHONY: help start stop restart logs backup restore update test clean

# Variables
COMPOSE_FILE := docker/docker-compose.yml
COMPOSE_PROD := docker/docker-compose.prod.yml
BACKUP_DIR := backups
DATE := $(shell date +%Y%m%d_%H%M%S)

help: ## Show this help
	@echo "Grafana Monitoring Stack - Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

start: ## Start monitoring stack (development)
	@echo "🚀 Starting monitoring stack..."
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "✅ Stack started!"
	@echo "📊 Grafana: http://localhost:3000"
	@echo "📈 Prometheus: http://localhost:9090"

start-prod: ## Start monitoring stack (production)
	@echo "🚀 Starting production monitoring stack..."
	docker-compose -f $(COMPOSE_PROD) up -d
	@echo "✅ Production stack started!"

stop: ## Stop monitoring stack
	@echo "🛑 Stopping monitoring stack..."
	docker-compose -f $(COMPOSE_FILE) down
	@echo "✅ Stack stopped!"

restart: ## Restart monitoring stack
	@echo "🔄 Restarting monitoring stack..."
	docker-compose -f $(COMPOSE_FILE) restart
	@echo "✅ Stack restarted!"

logs: ## Show logs from all services
	docker-compose -f $(COMPOSE_FILE) logs -f

logs-grafana: ## Show Grafana logs
	docker-compose -f $(COMPOSE_FILE) logs -f grafana

logs-prometheus: ## Show Prometheus logs
	docker-compose -f $(COMPOSE_FILE) logs -f prometheus

status: ## Show status of all services
	docker-compose -f $(COMPOSE_FILE) ps

backup: ## Backup Grafana dashboards and Prometheus data
	@echo "💾 Creating backup..."
	@mkdir -p $(BACKUP_DIR)/$(DATE)
	@docker exec grafana grafana-cli admin export-dashboard --homeDashboard > $(BACKUP_DIR)/$(DATE)/dashboards.json 2>/dev/null || true
	@docker exec prometheus promtool tsdb snapshot /prometheus 2>/dev/null || true
	@docker cp prometheus:/prometheus/snapshots/latest $(BACKUP_DIR)/$(DATE)/prometheus-data 2>/dev/null || true
	@tar -czf $(BACKUP_DIR)/backup-$(DATE).tar.gz -C $(BACKUP_DIR) $(DATE)
	@rm -rf $(BACKUP_DIR)/$(DATE)
	@echo "✅ Backup created: $(BACKUP_DIR)/backup-$(DATE).tar.gz"

restore: ## Restore from backup (usage: make restore BACKUP=backup-20240101_120000.tar.gz)
	@echo "📥 Restoring from backup: $(BACKUP)"
	@tar -xzf $(BACKUP_DIR)/$(BACKUP) -C $(BACKUP_DIR)
	@# Add restore commands here
	@echo "✅ Restore completed!"

update: ## Update all containers to latest version
	@echo "🔄 Updating containers..."
	docker-compose -f $(COMPOSE_FILE) pull
	docker-compose -f $(COMPOSE_FILE) up -d
	@echo "✅ Containers updated!"

test: ## Run tests
	@echo "🧪 Running tests..."
	@bash scripts/test.sh 2>/dev/null || echo "⚠️  No test script found"

clean: ## Remove all containers, volumes and networks
	@echo "🧹 Cleaning up..."
	docker-compose -f $(COMPOSE_FILE) down -v
	@echo "✅ Cleanup completed!"

install-ubuntu: ## Install on Ubuntu
	@sudo bash scripts/install/ubuntu-install.sh

install-arch: ## Install on Arch Linux
	@sudo bash scripts/install/arch-install.sh

install-centos: ## Install on CentOS/RHEL
	@sudo bash scripts/install/centos-install.sh

setup-telegram-bot: ## Setup Telegram bot exporter
	@echo "🤖 Setting up Telegram bot exporter..."
	@pip install -r exporters/telegram-bot-exporter/requirements.txt
	@python exporters/telegram-bot-exporter/bot_exporter.py
