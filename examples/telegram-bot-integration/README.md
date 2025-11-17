# Telegram Bot Integration Example

## Описание

Этот пример показывает, как интегрировать ваш Telegram бот с системой мониторинга Prometheus и Grafana.

## Возможности

- ✅ Автоматический сбор метрик бота
- ✅ Отслеживание количества пользователей
- ✅ Мониторинг обработанных сообщений
- ✅ Трекинг ошибок
- ✅ Измерение времени обработки
- ✅ Подсчет API вызовов

## Установка

### 1. Установите зависимости

```bash
pip install -r ../../exporters/telegram-bot-exporter/requirements.txt
```

### 2. Интегрируйте с вашим ботом

```python
from aiogram import Bot, Dispatcher
from exporters.telegram_bot_exporter.bot_exporter import (
    PrometheusMiddleware,
    start_metrics_server,
    update_active_users
)

# Запустите HTTP сервер для метрик
start_metrics_server(8000)

# Создайте бота
bot = Bot(token="YOUR_BOT_TOKEN")
dp = Dispatcher()

# Подключите middleware
dp.update.middleware(PrometheusMiddleware('my_awesome_bot'))

# Ваш код бота...
```

### 3. Добавьте exporter в Prometheus

Отредактируйте `prometheus/prometheus.yml`:

```yaml
scrape_configs:
  - job_name: 'telegram-bot'
    static_configs:
      - targets: ['bot-server:8000']
        labels:
          bot_name: 'my_awesome_bot'
```

### 4. Перезапустите Prometheus

```bash
# Docker
docker-compose restart prometheus

# Нативная установка
sudo systemctl restart prometheus
```

## Доступные метрики

### Счетчики (Counters)

- `telegram_bot_messages_total` - Всего обработано сообщений
  - Labels: `bot_name`, `chat_type`

- `telegram_bot_commands_total` - Всего обработано команд
  - Labels: `bot_name`, `command`

- `telegram_bot_errors_total` - Всего ошибок
  - Labels: `bot_name`, `error_type`

- `telegram_bot_api_calls_total` - Всего API вызовов
  - Labels: `bot_name`, `method`

### Gauges

- `telegram_bot_active_users` - Количество активных пользователей
  - Labels: `bot_name`

### Гистограммы (Histograms)

- `telegram_bot_processing_seconds` - Время обработки сообщений
  - Labels: `bot_name`

- `telegram_bot_message_size_bytes` - Размер сообщений
  - Labels: `bot_name`

## Примеры запросов Prometheus

### Общее количество сообщений

```promql
sum(telegram_bot_messages_total{bot_name="my_awesome_bot"})
```

### Скорость сообщений в секунду

```promql
rate(telegram_bot_messages_total{bot_name="my_awesome_bot"}[5m])
```

### Процент ошибок

```promql
sum(rate(telegram_bot_errors_total{bot_name="my_awesome_bot"}[5m])) 
/ 
sum(rate(telegram_bot_messages_total{bot_name="my_awesome_bot"}[5m])) 
* 100
```

### Среднее время обработки

```promql
histogram_quantile(
  0.5, 
  rate(telegram_bot_processing_seconds_bucket{bot_name="my_awesome_bot"}[5m])
)
```

### Самые популярные команды

```promql
topk(5, sum by (command) (telegram_bot_commands_total{bot_name="my_awesome_bot"}))
```

## Создание Dashboard в Grafana

### Автоматический импорт

1. Откройте Grafana (http://localhost:3000)
2. Перейдите в Dashboards → Import
3. Импортируйте файл `dashboards/telegram-bot-dashboard.json`

### Ручное создание

#### Panel 1: Общее количество сообщений

```promql
sum(telegram_bot_messages_total{bot_name="my_awesome_bot"})
```

#### Panel 2: Активные пользователи

```promql
telegram_bot_active_users{bot_name="my_awesome_bot"}
```

#### Panel 3: Скорость сообщений

```promql
rate(telegram_bot_messages_total{bot_name="my_awesome_bot"}[5m])
```

#### Panel 4: Ошибки

```promql
sum by (error_type) (
  rate(telegram_bot_errors_total{bot_name="my_awesome_bot"}[5m])
)
```

## Алертинг

### Пример alert rules

Создайте файл `prometheus/alerts/telegram-bot.yml`:

```yaml
groups:
  - name: telegram_bot
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate(telegram_bot_errors_total[5m])) 
          / 
          sum(rate(telegram_bot_messages_total[5m])) 
          > 0.05
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High error rate in Telegram bot"
          description: "Error rate is {{ $value | humanizePercentage }}"
      
      - alert: BotNotResponding
        expr: |
          rate(telegram_bot_messages_total[5m]) == 0
        for: 10m
        labels:
          severity: critical
        annotations:
          summary: "Telegram bot not processing messages"
          description: "No messages processed in the last 10 minutes"
      
      - alert: SlowProcessing
        expr: |
          histogram_quantile(0.95, 
            rate(telegram_bot_processing_seconds_bucket[5m])
          ) > 2
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "Slow message processing"
          description: "95th percentile processing time is {{ $value }}s"
```

## Полный пример бота

```python
#!/usr/bin/env python3
"""
Example Telegram Bot with Prometheus monitoring
Author: run-as-daemon.ru
"""

import asyncio
import logging
from aiogram import Bot, Dispatcher, types, F
from aiogram.filters import Command
from aiogram.types import Message

# Import monitoring
import sys
sys.path.append('../..')
from exporters.telegram_bot_exporter.bot_exporter import (
    PrometheusMiddleware,
    start_metrics_server,
    update_active_users,
    track_api_call
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Bot configuration
BOT_TOKEN = "YOUR_BOT_TOKEN"
BOT_NAME = "my_awesome_bot"

# Initialize bot
bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()

# Start metrics server
start_metrics_server(8000)

# Add monitoring middleware
dp.update.middleware(PrometheusMiddleware(BOT_NAME))

# Track active users (example)
active_users = set()

@dp.message(Command("start"))
async def cmd_start(message: Message):
    """Handle /start command"""
    active_users.add(message.from_user.id)
    update_active_users(BOT_NAME, len(active_users))
    
    await message.answer(
        "👋 Привет! Я бот с мониторингом!\n\n"
        "📊 Метрики доступны на http://localhost:8000/metrics"
    )

@dp.message(Command("stats"))
async def cmd_stats(message: Message):
    """Show bot statistics"""
    await message.answer(
        f"📈 Статистика бота:\n\n"
        f"👥 Активных пользователей: {len(active_users)}\n"
        f"📊 Метрики: http://localhost:8000/metrics"
    )

@dp.message(F.text)
async def echo_message(message: Message):
    """Echo all messages"""
    await message.answer(f"Вы написали: {message.text}")

async def main():
    """Start bot"""
    logger.info(f"Starting bot {BOT_NAME}")
    logger.info("Metrics available at http://localhost:8000/metrics")
    
    try:
        await dp.start_polling(bot)
    finally:
        await bot.session.close()

if __name__ == '__main__':
    asyncio.run(main())
```

## Docker Compose для бота

```yaml
version: '3.8'

services:
  telegram-bot:
    build: .
    container_name: telegram-bot
    restart: unless-stopped
    environment:
      - BOT_TOKEN=${BOT_TOKEN}
      - BOT_NAME=my_awesome_bot
    ports:
      - "8000:8000"
    networks:
      - monitoring

networks:
  monitoring:
    external: true
```

## Troubleshooting

### Метрики не отображаются

1. Проверьте, что HTTP сервер запущен:
```bash
curl http://localhost:8000/metrics
```

2. Проверьте конфигурацию Prometheus:
```bash
promtool check config prometheus/prometheus.yml
```

3. Проверьте targets в Prometheus:
http://localhost:9090/targets

### Бот не отвечает

Проверьте логи:
```bash
docker logs telegram-bot -f
```

## Дополнительные ресурсы

- [Prometheus Client Python](https://github.com/prometheus/client_python)
- [aiogram Documentation](https://docs.aiogram.dev/)
- [Grafana Dashboard Examples](https://grafana.com/grafana/dashboards/)

## Поддержка

За помощью в настройке обращайтесь:
- 🌐 [run-as-daemon.ru](https://run-as-daemon.ru)
- 💬 [@runas_daemon](https://t.me/runas_daemon)
