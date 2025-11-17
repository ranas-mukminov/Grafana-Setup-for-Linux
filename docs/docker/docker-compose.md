# Docker Compose Setup

## Быстрый старт

### Предварительные требования

- Docker 20.10+
- Docker Compose 2.0+

### Установка

1. Клонируйте репозиторий:
```bash
git clone https://github.com/ranas-mukminov/Grafana-Setup-for-Linux.git
cd Grafana-Setup-for-Linux
```

2. Создайте файл переменных окружения:
```bash
cp docker/.env.example docker/.env
```

3. Отредактируйте `.env` и установите надежные пароли:
```bash
nano docker/.env
```

4. Запустите стек:
```bash
make start
```

или вручную:
```bash
docker-compose -f docker/docker-compose.yml up -d
```

## Проверка статуса

```bash
make status
```

или:
```bash
docker-compose -f docker/docker-compose.yml ps
```

## Доступ к сервисам

- **Grafana**: http://localhost:3000
- **Prometheus**: http://localhost:9090
- **Node Exporter**: http://localhost:9100/metrics

## Просмотр логов

Все сервисы:
```bash
make logs
```

Только Grafana:
```bash
make logs-grafana
```

Только Prometheus:
```bash
make logs-prometheus
```

## Production Setup

Для production используйте `docker-compose.prod.yml`:

```bash
make start-prod
```

Этот compose-файл включает:
- Loki для логов
- Promtail для сбора логов
- cAdvisor для метрик контейнеров
- Alertmanager для алертов
- Watchtower для автообновлений

## Backup и Restore

### Создание бэкапа

```bash
make backup
```

Бэкап сохраняется в `backups/backup-YYYYMMDD_HHMMSS.tar.gz`

### Восстановление из бэкапа

```bash
make restore BACKUP=backup-20240101_120000.tar.gz
```

## Обновление

```bash
make update
```

## Остановка

```bash
make stop
```

## Полная очистка

⚠️ Это удалит все данные!

```bash
make clean
```

## Кастомизация

### Добавление своих дашбордов

Поместите JSON файлы дашбордов в:
```
grafana/dashboards/
```

Они будут автоматически загружены при старте.

### Настройка Prometheus

Отредактируйте `prometheus/prometheus.yml` для добавления своих targets.

### Настройка алертов

Создайте файлы алертов в:
```
prometheus/alerts/
```

## Troubleshooting

### Контейнеры не запускаются

Проверьте логи:
```bash
docker-compose -f docker/docker-compose.yml logs
```

### Проблемы с разрешениями

Убедитесь, что Docker имеет права на volume директории:
```bash
sudo chown -R 472:472 grafana/
```

### Недостаточно памяти

Увеличьте лимиты в docker-compose.yml:
```yaml
deploy:
  resources:
    limits:
      memory: 2G
```

## Интеграция с Telegram ботом

См. [Telegram Bot Integration](../../examples/telegram-bot-integration/)
