# Установка Grafana на openSUSE Leap

## Быстрая установка

Используйте автоматический скрипт установки:

```bash
git clone https://github.com/ranas-mukminov/Grafana-Setup-for-Linux.git
cd Grafana-Setup-for-Linux
sudo bash scripts/install/suse-install.sh
```

## Поддерживаемые версии

- openSUSE Leap 15.5+
- openSUSE Tumbleweed

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

Скрипт автоматически настраивает firewalld:

```bash
# Проверка правил
sudo firewall-cmd --list-all
```

Ручная настройка:
```bash
sudo firewall-cmd --permanent --add-port=3000/tcp  # Grafana
sudo firewall-cmd --permanent --add-port=9090/tcp  # Prometheus
sudo firewall-cmd --permanent --add-port=9100/tcp  # Node Exporter
sudo firewall-cmd --reload
```

## Ручная установка

### 1. Обновление системы

```bash
sudo zypper refresh
sudo zypper update -y
```

### 2. Установка Grafana

```bash
cat <<EOF | sudo tee /etc/zypp/repos.d/grafana.repo
[grafana]
name=grafana
baseurl=https://rpm.grafana.com
type=rpm-md
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://rpm.grafana.com/gpg.key
EOF

sudo zypper refresh
sudo zypper install -y grafana
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

### 4. Создание systemd сервиса для Prometheus

```bash
sudo tee /etc/systemd/system/prometheus.service << EOF
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
    --storage.tsdb.path=/var/lib/prometheus/

[Install]
WantedBy=multi-user.target
EOF
```

### 5. Запуск сервисов

```bash
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl enable prometheus
sudo systemctl start grafana-server
sudo systemctl start prometheus
```

## Конфигурация

### Grafana

Файл конфигурации: `/etc/grafana/grafana.ini`

```bash
sudo nano /etc/grafana/grafana.ini
```

### Prometheus

Файл конфигурации: `/etc/prometheus/prometheus.yml`

```bash
sudo nano /etc/prometheus/prometheus.yml
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

### Firewall блокирует подключения

Проверьте правила:
```bash
sudo firewall-cmd --list-all
```

## YaST - графический менеджер

openSUSE предоставляет YaST для управления:

```bash
sudo yast2
```

В YaST можно:
- Настроить firewall
- Управлять сервисами
- Настроить сеть

## Docker на openSUSE

### Установка Docker

```bash
sudo zypper install -y docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

После добавления в группу docker, перелогиньтесь.

### Использование Docker Compose

```bash
cd Grafana-Setup-for-Linux
make start
```

## Podman на openSUSE

```bash
sudo zypper install -y podman podman-compose
```

Использование:
```bash
podman-compose -f docker/docker-compose.yml up -d
```

## Дополнительная настройка

### SSL/TLS

Для настройки HTTPS следуйте [Security Best Practices](../advanced/security.md)

### High Availability

Для настройки HA кластера см. [HA Setup Guide](../advanced/ha-setup.md)

## Полезные команды openSUSE

### Поиск пакетов

```bash
zypper search grafana
```

### Информация о пакете

```bash
zypper info grafana
```

### Обновление системы

```bash
sudo zypper refresh
sudo zypper update
```

### Очистка кэша

```bash
sudo zypper clean
```

### Управление сервисами

```bash
sudo systemctl status grafana-server
sudo systemctl restart grafana-server
sudo systemctl stop grafana-server
```

### Просмотр логов

```bash
sudo journalctl -u grafana-server -n 100
sudo journalctl -u prometheus -n 100
```

## Особенности openSUSE

### Снапшоты Btrfs

openSUSE использует Btrfs с автоматическими снапшотами:

```bash
# Просмотр снапшотов
sudo snapper list

# Создание снапшота перед установкой
sudo snapper create --description "Before Grafana install"

# Откат к снапшоту (при необходимости)
sudo snapper rollback <number>
```

### AppArmor

openSUSE использует AppArmor для безопасности:

```bash
# Проверка статуса
sudo aa-status

# При необходимости настройки профилей
sudo aa-complain grafana-server
```
