# Установка Grafana на Arch Linux

## Быстрая установка

Используйте автоматический скрипт установки:

```bash
git clone https://github.com/ranas-mukminov/Grafana-Setup-for-Linux.git
cd Grafana-Setup-for-Linux
sudo bash scripts/install/arch-install.sh
```

## Что устанавливается

Скрипт автоматически устанавливает и настраивает:

- **Grafana** - из официального репозитория Arch
- **Prometheus** - сервер метрик
- **Node Exporter** - экспортер системных метрик
- **Docker & Podman** - для контейнерных развертываний

## Проверка установки

После установки проверьте статус сервисов:

```bash
sudo systemctl status grafana
sudo systemctl status prometheus
sudo systemctl status prometheus-node-exporter
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

### 1. Обновление системы

```bash
sudo pacman -Syu
```

### 2. Установка Grafana

```bash
sudo pacman -S grafana
```

### 3. Установка Prometheus

```bash
sudo pacman -S prometheus
```

### 4. Установка Node Exporter

```bash
sudo pacman -S prometheus-node-exporter
```

### 5. Установка из AUR (опционально)

Для Loki и других компонентов:

```bash
yay -S loki-bin
yay -S promtail-bin
```

### 6. Запуск сервисов

```bash
sudo systemctl enable --now grafana
sudo systemctl enable --now prometheus
sudo systemctl enable --now prometheus-node-exporter
```

## Конфигурация

### Grafana

Файл конфигурации: `/etc/grafana.ini`

```bash
sudo nano /etc/grafana.ini
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
sudo journalctl -u grafana -f
```

### Prometheus не может подключиться

Проверьте конфигурацию:
```bash
promtool check config /etc/prometheus/prometheus.yml
```

### Проблемы с разрешениями

```bash
sudo chown -R grafana:grafana /var/lib/grafana
sudo chown -R prometheus:prometheus /var/lib/prometheus
```

## Docker на Arch Linux

### Установка Docker

```bash
sudo pacman -S docker docker-compose
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

После добавления в группу docker, перелогиньтесь.

### Использование Docker Compose

```bash
cd Grafana-Setup-for-Linux
make start
```

## Podman на Arch Linux

Podman - альтернатива Docker без демона:

```bash
sudo pacman -S podman podman-compose
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

## Полезные команды Arch Linux

### Очистка пакетов

```bash
sudo pacman -Sc
```

### Обновление системы

```bash
sudo pacman -Syu
```

### Поиск пакетов

```bash
pacman -Ss grafana
```

### Информация о пакете

```bash
pacman -Qi grafana
```
