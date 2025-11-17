# Установка Grafana на Ubuntu 22.04/24.04

## Быстрая установка

Используйте автоматический скрипт установки:

```bash
git clone https://github.com/ranas-mukminov/Grafana-Setup-for-Linux.git
cd Grafana-Setup-for-Linux
sudo bash scripts/install/ubuntu-install.sh
```

## Что устанавливается

Скрипт автоматически устанавливает и настраивает:

- **Grafana** - последняя стабильная версия
- **Prometheus** - сервер метрик
- **Node Exporter** - экспортер системных метрик

## Проверка установки

После установки проверьте статус сервисов:

```bash
sudo systemctl status grafana-server
sudo systemctl status prometheus
sudo systemctl status node_exporter
```

## Доступ к сервисам

- **Grafana**: http://localhost:3000
  - Логин: `admin`
  - Пароль: `admin` (измените при первом входе)

- **Prometheus**: http://localhost:9090

## Настройка firewall

Если используете UFW:

```bash
sudo ufw allow 3000/tcp  # Grafana
sudo ufw allow 9090/tcp  # Prometheus
```

## Ручная установка

### 1. Установка зависимостей

```bash
sudo apt-get update
sudo apt-get install -y apt-transport-https software-properties-common wget curl
```

### 2. Установка Grafana

```bash
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt-get update
sudo apt-get install -y grafana
```

### 3. Установка Prometheus

```bash
PROM_VERSION="2.48.0"
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz
tar xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz
sudo cp prometheus-${PROM_VERSION}.linux-amd64/prometheus /usr/local/bin/
sudo cp prometheus-${PROM_VERSION}.linux-amd64/promtool /usr/local/bin/
```

### 4. Запуск сервисов

```bash
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

## Устранение неполадок

### Grafana не запускается

Проверьте логи:
```bash
sudo journalctl -u grafana-server -f
```

### Prometheus не может подключиться

Проверьте конфигурацию:
```bash
promtool check config /etc/prometheus/prometheus.yml
```

## Дополнительная настройка

### SSL/TLS

Для настройки HTTPS следуйте [Security Best Practices](../advanced/security.md)

### High Availability

Для настройки HA кластера см. [HA Setup Guide](../advanced/ha-setup.md)
