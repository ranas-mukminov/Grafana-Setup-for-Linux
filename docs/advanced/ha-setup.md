# High Availability Setup

## Архитектура HA

```
                    ┌─────────────┐
                    │ Load Balancer│
                    │  (HAProxy)   │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼────┐        ┌───▼────┐        ┌───▼────┐
    │Grafana1│        │Grafana2│        │Grafana3│
    └───┬────┘        └───┬────┘        └───┬────┘
        │                  │                  │
        └──────────────────┼──────────────────┘
                           │
                    ┌──────▼──────┐
                    │  PostgreSQL  │
                    │   Cluster    │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼────┐        ┌───▼────┐        ┌───▼────┐
    │Prom1   │        │Prom2   │        │Prom3   │
    └────────┘        └────────┘        └────────┘
```

## Компоненты HA

### 1. PostgreSQL для Grafana

Вместо встроенной SQLite используйте PostgreSQL:

#### Установка PostgreSQL

```bash
# Ubuntu
sudo apt install postgresql postgresql-contrib

# Arch
sudo pacman -S postgresql

# CentOS
sudo dnf install postgresql-server postgresql-contrib
```

#### Создание базы данных

```sql
CREATE USER grafana WITH PASSWORD 'secure_password';
CREATE DATABASE grafana;
GRANT ALL PRIVILEGES ON DATABASE grafana TO grafana;
```

#### Конфигурация Grafana

```ini
# /etc/grafana/grafana.ini
[database]
type = postgres
host = postgres.example.com:5432
name = grafana
user = grafana
password = secure_password
ssl_mode = require
```

### 2. HAProxy Load Balancer

#### Установка

```bash
sudo apt install haproxy  # Ubuntu
sudo pacman -S haproxy    # Arch
sudo dnf install haproxy  # CentOS
```

#### Конфигурация

```
# /etc/haproxy/haproxy.cfg
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend grafana_frontend
    bind *:80
    bind *:443 ssl crt /etc/ssl/certs/grafana.pem
    redirect scheme https if !{ ssl_fc }
    default_backend grafana_backend

backend grafana_backend
    balance roundrobin
    option httpchk GET /api/health
    http-check expect status 200
    
    server grafana1 10.0.0.11:3000 check inter 2000 rise 2 fall 3
    server grafana2 10.0.0.12:3000 check inter 2000 rise 2 fall 3
    server grafana3 10.0.0.13:3000 check inter 2000 rise 2 fall 3

frontend prometheus_frontend
    bind *:9090
    default_backend prometheus_backend

backend prometheus_backend
    balance roundrobin
    option httpchk GET /-/healthy
    http-check expect status 200
    
    server prom1 10.0.0.21:9090 check inter 2000 rise 2 fall 3
    server prom2 10.0.0.22:9090 check inter 2000 rise 2 fall 3
    server prom3 10.0.0.23:9090 check inter 2000 rise 2 fall 3

listen stats
    bind *:8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE
```

### 3. Prometheus HA

#### Конфигурация с внешними labels

Каждый Prometheus instance должен иметь уникальный external_label:

```yaml
# prometheus1.yml
global:
  scrape_interval: 15s
  external_labels:
    cluster: 'monitoring'
    replica: '0'

# prometheus2.yml
global:
  scrape_interval: 15s
  external_labels:
    cluster: 'monitoring'
    replica: '1'

# prometheus3.yml
global:
  scrape_interval: 15s
  external_labels:
    cluster: 'monitoring'
    replica: '2'
```

#### Использование Thanos для долгосрочного хранения

Установка Thanos:

```bash
# Скачать бинарники
THANOS_VERSION="0.32.5"
wget https://github.com/thanos-io/thanos/releases/download/v${THANOS_VERSION}/thanos-${THANOS_VERSION}.linux-amd64.tar.gz
tar xzf thanos-${THANOS_VERSION}.linux-amd64.tar.gz
sudo cp thanos-${THANOS_VERSION}.linux-amd64/thanos /usr/local/bin/
```

Конфигурация Thanos Sidecar:

```yaml
# prometheus.yml
global:
  external_labels:
    cluster: monitoring
    replica: 0

# Добавить Thanos sidecar
thanos:
  sidecar:
    prometheus_url: http://localhost:9090
    tsdb_path: /var/lib/prometheus
    grpc_address: 0.0.0.0:10901
    http_address: 0.0.0.0:10902
```

### 4. Grafana Clustering

#### Используя Redis для session storage

```ini
# /etc/grafana/grafana.ini
[session]
provider = redis
provider_config = addr=redis.example.com:6379,pool_size=100,db=grafana

[remote_cache]
type = redis
connstr = addr=redis.example.com:6379,pool_size=100,db=0
```

#### Docker Compose HA Setup

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: grafana
      POSTGRES_USER: grafana
      POSTGRES_PASSWORD: secure_password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - monitoring

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    networks:
      - monitoring

  grafana1:
    image: grafana/grafana:latest
    environment:
      - GF_DATABASE_TYPE=postgres
      - GF_DATABASE_HOST=postgres:5432
      - GF_DATABASE_NAME=grafana
      - GF_DATABASE_USER=grafana
      - GF_DATABASE_PASSWORD=secure_password
      - GF_SESSION_PROVIDER=redis
      - GF_SESSION_PROVIDER_CONFIG=addr=redis:6379
    depends_on:
      - postgres
      - redis
    networks:
      - monitoring

  grafana2:
    image: grafana/grafana:latest
    environment:
      - GF_DATABASE_TYPE=postgres
      - GF_DATABASE_HOST=postgres:5432
      - GF_DATABASE_NAME=grafana
      - GF_DATABASE_USER=grafana
      - GF_DATABASE_PASSWORD=secure_password
      - GF_SESSION_PROVIDER=redis
      - GF_SESSION_PROVIDER_CONFIG=addr=redis:6379
    depends_on:
      - postgres
      - redis
    networks:
      - monitoring

  haproxy:
    image: haproxy:2.8-alpine
    ports:
      - "80:80"
      - "443:443"
      - "8404:8404"
    volumes:
      - ./haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro
    depends_on:
      - grafana1
      - grafana2
    networks:
      - monitoring

volumes:
  postgres-data:
  redis-data:

networks:
  monitoring:
    driver: bridge
```

### 5. Keepalived для VRRP

Для отказоустойчивого load balancer:

```bash
# Установка
sudo apt install keepalived  # Ubuntu
sudo pacman -S keepalived    # Arch
sudo dnf install keepalived  # CentOS
```

Конфигурация Master:

```
# /etc/keepalived/keepalived.conf
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 101
    advert_int 1
    
    authentication {
        auth_type PASS
        auth_pass secret123
    }
    
    virtual_ipaddress {
        192.168.1.100/24
    }
}
```

Конфигурация Backup:

```
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    
    authentication {
        auth_type PASS
        auth_pass secret123
    }
    
    virtual_ipaddress {
        192.168.1.100/24
    }
}
```

### 6. Мониторинг HA

Создайте дашборд для мониторинга кластера:

- Статус всех nodes
- Load balancer metrics
- Database connections
- Replication lag
- Health checks

### 7. Disaster Recovery

#### Бэкап стратегия

```bash
#!/bin/bash
# backup-ha.sh

# PostgreSQL backup
pg_dump -h postgres.example.com -U grafana grafana > /backup/grafana-$(date +%Y%m%d).sql

# Redis backup
redis-cli -h redis.example.com BGSAVE

# Конфигурационные файлы
tar -czf /backup/configs-$(date +%Y%m%d).tar.gz \
    /etc/grafana/ \
    /etc/prometheus/ \
    /etc/haproxy/
```

#### Восстановление

```bash
# Восстановление PostgreSQL
psql -h postgres.example.com -U grafana grafana < /backup/grafana-20240101.sql

# Восстановление конфигураций
tar -xzf /backup/configs-20240101.tar.gz -C /
```

## Kubernetes HA Deployment

Для Kubernetes используйте StatefulSet:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: grafana
spec:
  serviceName: grafana
  replicas: 3
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
      - name: grafana
        image: grafana/grafana:latest
        env:
        - name: GF_DATABASE_TYPE
          value: postgres
        - name: GF_DATABASE_HOST
          value: postgres-service:5432
        volumeMounts:
        - name: grafana-storage
          mountPath: /var/lib/grafana
  volumeClaimTemplates:
  - metadata:
      name: grafana-storage
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: 10Gi
```

## Тестирование HA

### 1. Failover тест

```bash
# Остановка одного из Grafana
sudo systemctl stop grafana-server

# Проверка доступности через Load Balancer
curl -I http://load-balancer.example.com
```

### 2. Split-brain тест

Симулируйте сетевой раздел и проверьте поведение.

### 3. Load тест

```bash
# Используйте k6 или Apache Bench
k6 run --vus 100 --duration 30s loadtest.js
```

## Чек-лист HA

- [ ] PostgreSQL настроен и реплицируется
- [ ] Redis для session storage
- [ ] Load balancer (HAProxy) настроен
- [ ] Keepalived для VRRP
- [ ] Мониторинг всех компонентов
- [ ] Автоматический бэкап
- [ ] Documented recovery procedures
- [ ] Проведены failover тесты
- [ ] Alert rules для HA компонентов

## Рекомендации

1. **Минимум 3 ноды** для кворума
2. **Разные availability zones** для устойчивости
3. **Автоматическое восстановление** при сбоях
4. **Регулярное тестирование** failover сценариев
5. **Документация** всех процедур

## Дополнительные ресурсы

- [Grafana HA Documentation](https://grafana.com/docs/grafana/latest/setup-grafana/set-up-for-high-availability/)
- [Prometheus HA](https://prometheus.io/docs/introduction/faq/#can-prometheus-be-made-highly-available)
- [HAProxy Best Practices](http://www.haproxy.org/download/2.8/doc/configuration.txt)
