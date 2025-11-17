# Security Best Practices

## Общие рекомендации

### 1. Изменение паролей по умолчанию

⚠️ **КРИТИЧНО**: Всегда меняйте пароли по умолчанию!

```bash
# Grafana
grafana-cli admin reset-admin-password <new-password>
```

Или через веб-интерфейс при первом входе.

### 2. Использование HTTPS/TLS

#### С помощью Nginx Reverse Proxy

Установка Nginx:
```bash
sudo apt install nginx certbot python3-certbot-nginx  # Ubuntu
sudo pacman -S nginx certbot certbot-nginx             # Arch
sudo dnf install nginx certbot python3-certbot-nginx  # CentOS
```

Конфигурация Nginx:
```nginx
# /etc/nginx/sites-available/grafana
server {
    listen 80;
    server_name grafana.example.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name grafana.example.com;

    ssl_certificate /etc/letsencrypt/live/grafana.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/grafana.example.com/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Получение сертификата Let's Encrypt:
```bash
sudo certbot --nginx -d grafana.example.com
```

#### Встроенный HTTPS в Grafana

Редактируйте `/etc/grafana/grafana.ini`:

```ini
[server]
protocol = https
cert_file = /path/to/cert.pem
cert_key = /path/to/key.pem
```

### 3. Настройка аутентификации

#### LDAP/Active Directory

```ini
# /etc/grafana/grafana.ini
[auth.ldap]
enabled = true
config_file = /etc/grafana/ldap.toml
allow_sign_up = true
```

Конфигурация LDAP (`/etc/grafana/ldap.toml`):
```toml
[[servers]]
host = "ldap.example.com"
port = 389
use_ssl = false
start_tls = true
bind_dn = "cn=admin,dc=example,dc=com"
bind_password = 'secret'
search_filter = "(cn=%s)"
search_base_dns = ["dc=example,dc=com"]
```

#### OAuth (Google, GitHub, GitLab)

```ini
[auth.google]
enabled = true
client_id = YOUR_CLIENT_ID
client_secret = YOUR_CLIENT_SECRET
scopes = https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email
auth_url = https://accounts.google.com/o/oauth2/auth
token_url = https://accounts.google.com/o/oauth2/token
allowed_domains = example.com
```

### 4. Ограничение доступа по IP

#### Через Nginx

```nginx
location / {
    # Разрешить только определенные IP
    allow 192.168.1.0/24;
    allow 10.0.0.0/8;
    deny all;
    
    proxy_pass http://localhost:3000;
}
```

#### Через firewall

```bash
# UFW
sudo ufw allow from 192.168.1.0/24 to any port 3000

# firewalld
sudo firewall-cmd --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" port port="3000" protocol="tcp" accept'
sudo firewall-cmd --reload
```

### 5. Роли и разрешения

Используйте встроенные роли Grafana:

- **Admin**: Полный доступ
- **Editor**: Может создавать и редактировать дашборды
- **Viewer**: Только просмотр

Создание пользователя:
```bash
grafana-cli admin create-user --name "john" --email "john@example.com" --password "secret" --role Viewer
```

### 6. API ключи

Создавайте отдельные API ключи для каждого приложения:

```bash
# Через веб-интерфейс: Configuration → API Keys
```

Используйте ключи с ограниченными правами.

### 7. Регулярные бэкапы

#### Автоматический бэкап

Создайте скрипт бэкапа:

```bash
#!/bin/bash
# /opt/grafana-backup/backup.sh

BACKUP_DIR="/backup/grafana"
DATE=$(date +%Y%m%d_%H%M%S)

# Бэкап SQLite базы данных
cp /var/lib/grafana/grafana.db "$BACKUP_DIR/grafana-$DATE.db"

# Бэкап конфигурации
cp -r /etc/grafana "$BACKUP_DIR/config-$DATE"

# Бэкап дашбордов
cp -r /var/lib/grafana/dashboards "$BACKUP_DIR/dashboards-$DATE"

# Удаление старых бэкапов (старше 30 дней)
find "$BACKUP_DIR" -name "grafana-*" -mtime +30 -delete

echo "Backup completed: $DATE"
```

Добавьте в cron:
```bash
sudo crontab -e
0 2 * * * /opt/grafana-backup/backup.sh
```

### 8. Prometheus Security

#### Basic Auth

Используйте Nginx или другой reverse proxy для Basic Auth:

```nginx
location /prometheus/ {
    auth_basic "Prometheus";
    auth_basic_user_file /etc/nginx/.htpasswd;
    proxy_pass http://localhost:9090/;
}
```

Создание пользователя:
```bash
sudo htpasswd -c /etc/nginx/.htpasswd admin
```

#### Отключение опасных API

В `prometheus.yml`:
```yaml
global:
  ...

# Отключить admin API
web:
  enable_admin_api: false
```

### 9. Обновления и патчи

Регулярно обновляйте все компоненты:

```bash
# Docker
make update

# Нативная установка
sudo apt update && sudo apt upgrade grafana prometheus  # Ubuntu
sudo pacman -Syu grafana prometheus                     # Arch
sudo dnf update grafana                                  # CentOS
```

### 10. Мониторинг безопасности

#### Audit логи

Включите audit логи в Grafana:

```ini
[log]
mode = console file
level = info

[log.console]
level = info

[log.file]
level = info
log_rotate = true
max_lines = 1000000
max_size_shift = 28
daily_rotate = true
max_days = 7
```

#### Алерты безопасности

Настройте алерты на:
- Неудачные попытки входа
- Изменения в конфигурации
- Необычная активность API

### 11. Network Security

#### Изоляция сети

Используйте Docker network или VLANs:

```yaml
# docker-compose.yml
networks:
  monitoring:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
```

#### Шифрование между компонентами

Используйте mTLS между Prometheus и exporters.

### 12. Compliance

#### GDPR

- Анонимизируйте пользовательские данные
- Настройте автоматическое удаление старых данных
- Документируйте обработку данных

#### Logging

Логируйте все административные действия:

```ini
[log]
mode = console file
level = info

[auditing]
enabled = true
log_dashboard_save = true
```

## Чек-лист безопасности

- [ ] Изменены пароли по умолчанию
- [ ] Настроен HTTPS/TLS
- [ ] Настроена аутентификация (LDAP/OAuth)
- [ ] Ограничен доступ по IP
- [ ] Настроены роли и разрешения
- [ ] Созданы API ключи с ограниченными правами
- [ ] Настроен автоматический бэкап
- [ ] Включены audit логи
- [ ] Настроен firewall
- [ ] Отключены ненужные API
- [ ] Регулярные обновления
- [ ] Мониторинг безопасности

## Дополнительные ресурсы

- [Grafana Security](https://grafana.com/docs/grafana/latest/administration/security/)
- [Prometheus Security](https://prometheus.io/docs/operating/security/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
