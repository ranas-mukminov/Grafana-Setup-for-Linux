# 🎯 Grafana Setup для Linux - Полное руководство

<div align="center">

[![Grafana](https://img.shields.io/badge/Grafana-11.x-orange.svg)](https://grafana.com/)
[![Prometheus](https://img.shields.io/badge/Prometheus-2.x-red.svg)](https://prometheus.io/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-Ready-326CE5.svg)](https://kubernetes.io/)

**Современное руководство по установке и настройке Grafana на Linux**

[English](README.md) | **Русский**

</div>

---

## 👨‍💻 Об авторе

Привет! Я DevOps инженер и системный администратор с опытом работы в сложных инфраструктурах.

**Мои услуги:**
- 🔧 Настройка систем мониторинга (Grafana, Prometheus, Loki)
- 🐳 Контейнеризация приложений (Docker, Podman, Kubernetes)
- 🤖 Разработка Telegram ботов с интеграцией мониторинга
- 🚀 DevOps автоматизация и CI/CD pipeline
- 📊 Построение систем сбора и визуализации метрик
- 🔐 Настройка безопасности и резервного копирования

### 📱 Связаться со мной

- 🌐 **Сайт:** [run-as-daemon.ru](https://run-as-daemon.ru)
- 🔗 **GitHub:** [@ranas-mukminov](https://github.com/ranas-mukminov)
- 📧 **Email:** 79997679000@mail.ru
- 💬 **Telegram:** [@runas_daemon](https://t.me/runas_daemon)

### 💼 Портфолио проектов

На моём [блоге](https://run-as-daemon.ru) вы найдёте:
- Кейсы по настройке мониторинга
- Уникальный опыт администрирования серверов на высоте 10,000 метров ✈️
- Решения для автоматизации инфраструктуры
- Интеграция Telegram ботов с системами мониторинга

---

## 🎯 Что внутри этого репозитория?

Полный набор инструментов и документации для развертывания **production-ready** систем мониторинга на базе Grafana:

### ✨ Особенности

- ⚡ **Быстрый старт** - установка за 5 минут
- 🐳 **Docker/Podman ready** - полностью контейнеризованные решения
- ☸️ **Kubernetes манифесты** - для облачных развертываний
- 🔄 **Автоматизация** - Ansible playbooks для массового деплоя
- 📊 **Готовые дашборды** - для системного мониторинга и Telegram ботов
- 🔐 **Production security** - SSL, аутентификация, бэкапы
- 🎨 **Тёмная тема** - готовая кастомизация под ваш бренд

---

## 🚀 Быстрый старт

### Вариант 1: Docker Compose (рекомендуется)

```bash
# Клонируем репозиторий
git clone https://github.com/ranas-mukminov/Grafana-Setup-for-Linux.git
cd Grafana-Setup-for-Linux

# Копируем и настраиваем переменные
cp docker/.env.example docker/.env
nano docker/.env  # Установите свои пароли

# Запускаем стек мониторинга
make start

# Проверяем статус
make status

# Открываем Grafana
# http://localhost:3000
# Логин: admin
# Пароль: смотри в .env
```

### Вариант 2: Нативная установка

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

### Вариант 3: Kubernetes (Helm)

```bash
# Добавляем Helm репозиторий
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Устанавливаем с нашими настройками
helm install grafana grafana/grafana \
  -f kubernetes/helm/values.yaml \
  --namespace monitoring \
  --create-namespace
```

---

## 📚 Поддерживаемые дистрибутивы

| Дистрибутив | Версии | Статус | Скрипт установки |
|------------|--------|--------|------------------|
| Ubuntu | 22.04, 24.04 | ✅ Протестировано | `scripts/install/ubuntu-install.sh` |
| Debian | 11, 12 | ✅ Протестировано | `scripts/install/ubuntu-install.sh` |
| Arch Linux | Rolling | ✅ Протестировано | `scripts/install/arch-install.sh` |
| CentOS | 9 Stream | ✅ Протестировано | `scripts/install/centos-install.sh` |
| RHEL | 9.x | ✅ Протестировано | `scripts/install/centos-install.sh` |
| Rocky Linux | 9.x | ✅ Протестировано | `scripts/install/centos-install.sh` |
| openSUSE | Leap 15.5+ | ✅ Протестировано | `scripts/install/suse-install.sh` |

---

## 🎨 Готовые дашборды

### 1. Мониторинг системы

- CPU, Memory, Disk, Network
- Процессы и сервисы
- Температура и uptime

### 2. Docker контейнеры

- Статус контейнеров
- Использование ресурсов
- Логи в реальном времени

### 3. Kubernetes кластер

- Статус подов и нод
- Resource quotas
- Namespace metrics

### 4. Telegram боты (специально для разработчиков)

- Количество пользователей
- Обработанные сообщения
- Ошибки и performance
- API calls статистика

---

## 🔧 Архитектура решения

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

## 🛠️ Продвинутые возможности

### High Availability (HA)

```bash
# Разворачиваем HA кластер
ansible-playbook ansible/playbook.yml -i ansible/inventory/production
```

### Интеграция с Telegram ботами

```python
# Пример экспортера метрик для вашего бота
from prometheus_client import start_http_server, Counter, Gauge

bot_messages = Counter('bot_messages_total', 'Total messages')
active_users = Gauge('bot_active_users', 'Active users')

# Запускаем exporter на порту 8000
start_http_server(8000)
```

### Автоматический бэкап

```bash
# Настроим ежедневный бэкап в 2:00
sudo crontab -e
0 2 * * * /opt/grafana-backup/backup.sh
```

---

## 📖 Полная документация

- 📘 [Установка на Ubuntu](docs/installation/ubuntu-22.04-24.04.md)
- 📗 [Установка на Arch Linux](docs/installation/arch-linux.md)
- 📙 [Установка на CentOS/RHEL](docs/installation/centos-rhel-9.md)
- 📕 [Установка на openSUSE](docs/installation/opensuse-leap.md)
- 🐳 [Docker Compose setup](docs/docker/docker-compose.md)
- ☸️ [Kubernetes Helm setup](docs/kubernetes/helm-installation.md)
- 🔐 [Security Best Practices](docs/advanced/security.md)
- 🔄 [High Availability Setup](docs/advanced/ha-setup.md)

---

## 💡 Полезные команды

```bash
# Просмотр всех доступных команд
make help

# Старт стека
make start

# Остановка
make stop

# Перезапуск
make restart

# Просмотр логов
make logs

# Бэкап данных
make backup

# Восстановление из бэкапа
make restore

# Обновление до последней версии
make update

# Тесты
make test
```

---

## 🤝 Нужна помощь?

### 💼 Профессиональные услуги

Предлагаю следующие услуги по установке и настройке систем мониторинга:

#### 📦 Базовый пакет
- Установка Grafana + Prometheus
- Настройка базовых дашбордов
- Документация
- **Цена:** договорная

#### 🚀 Продвинутый пакет
- Полный LGTM стек (Loki + Grafana + Tempo + Mimir)
- Кастомные дашборды под ваши задачи
- Интеграция с существующей инфраструктурой
- Настройка алертинга
- Обучение команды
- **Цена:** договорная

#### 🏢 Корпоративный пакет
- High Availability кластер
- Multi-tenancy настройка
- Интеграция с AD/LDAP
- Custom плагины и экспортеры
- SLA поддержка
- **Цена:** договорная

### 📞 Консультации

- **Разовая консультация (1 час):** договорная
- **Техническая поддержка (месяц):** договорная
- **Разработка custom решений:** индивидуально

### 🎓 Обучение

Провожу индивидуальное и корпоративное обучение по темам:
- Grafana для начинающих
- Prometheus и система метрик
- DevOps мониторинг best practices
- Telegram боты с мониторингом

**Связаться:** [run-as-daemon.ru](https://run-as-daemon.ru)

---

## 🤝 Вклад в проект

Приветствуются Pull Requests! Перед отправкой:

1. Создайте issue с описанием проблемы/улучшения
2. Форкните репозиторий
3. Создайте feature branch
4. Протестируйте изменения
5. Отправьте PR

---

## 📝 Лицензия

MIT License - см. [LICENSE](LICENSE)

---

## ⭐ Благодарности

Если этот проект помог вам - поставьте звезду! ⭐

Подписывайтесь на мой [блог](https://run-as-daemon.ru) для новых кейсов и туториалов.

---

<div align="center">

**Made with ❤️ by [Ranas Mukminov](https://run-as-daemon.ru)**

[⬆ Вернуться к началу](#-grafana-setup-для-linux---полное-руководство)

</div>
