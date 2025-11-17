# Contributing to Grafana-Setup-for-Linux

Спасибо за ваш интерес к улучшению проекта! 🎉

## Как внести вклад

### Reporting Issues

Если вы нашли баг или хотите предложить улучшение:

1. Проверьте, что похожая issue ещё не создана
2. Создайте новую issue с подробным описанием:
   - Ваша ОС и версия
   - Шаги для воспроизведения
   - Ожидаемое и фактическое поведение
   - Логи (если применимо)

### Pull Requests

1. **Fork** репозиторий
2. Создайте **feature branch**:
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Внесите изменения
4. **Протестируйте** изменения:
   ```bash
   # Проверка синтаксиса скриптов
   bash -n scripts/install/*.sh
   
   # Проверка Docker Compose
   docker compose -f docker/docker-compose.yml config
   
   # Проверка Python
   python3 -m py_compile exporters/telegram-bot-exporter/bot_exporter.py
   ```
5. **Commit** с понятным сообщением:
   ```bash
   git commit -m "feat: add support for Debian 12"
   ```
6. **Push** в ваш fork:
   ```bash
   git push origin feature/amazing-feature
   ```
7. Создайте **Pull Request**

## Coding Guidelines

### Shell Scripts

- Используйте `#!/bin/bash` shebang
- Добавляйте `set -e` для выхода при ошибке
- Используйте функции для повторяющегося кода
- Добавляйте комментарии для сложной логики
- Делайте скрипты executable: `chmod +x script.sh`

Пример:
```bash
#!/bin/bash
set -e

# Function description
function do_something() {
    echo "Doing something..."
}
```

### Docker Compose

- Используйте named volumes
- Добавляйте restart policies
- Используйте environment variables для конфигурации
- Документируйте порты и networks

### Documentation

- Документация на русском и английском
- Используйте Markdown
- Добавляйте примеры кода
- Включайте скриншоты (где уместно)

### Commit Messages

Используйте conventional commits:

- `feat:` - новая функциональность
- `fix:` - исправление бага
- `docs:` - изменения в документации
- `style:` - форматирование, без изменения кода
- `refactor:` - рефакторинг кода
- `test:` - добавление тестов
- `chore:` - обслуживание проекта

Примеры:
```
feat: add Arch Linux installation script
fix: correct Prometheus port in docker-compose
docs: update Ubuntu installation guide
```

## Что можно добавить

### Высокоприоритетные

- [ ] Дополнительные дашборды для Grafana
- [ ] Больше примеров интеграции с Telegram ботами
- [ ] Ansible roles для автоматизации
- [ ] Kubernetes манифесты
- [ ] Тесты для скриптов установки

### Среднеприоритетные

- [ ] Поддержка других дистрибутивов Linux
- [ ] Интеграция с другими системами мониторинга
- [ ] Примеры настройки алертов
- [ ] Видео-туториалы
- [ ] Переводы документации на другие языки

### Низкоприоритетные

- [ ] GUI для управления конфигурацией
- [ ] Веб-интерфейс для установки
- [ ] Mobile app для мониторинга

## Структура проекта

```
Grafana-Setup-for-Linux/
├── docs/                    # Документация
│   ├── installation/        # Гайды по установке
│   ├── docker/              # Docker документация
│   ├── kubernetes/          # K8s документация
│   └── advanced/            # Продвинутые темы
├── scripts/                 # Скрипты установки
│   ├── install/             # Скрипты установки
│   ├── configure/           # Скрипты конфигурации
│   └── maintenance/         # Скрипты обслуживания
├── docker/                  # Docker Compose файлы
├── kubernetes/              # Kubernetes манифесты
├── ansible/                 # Ansible playbooks
├── grafana/                 # Grafana конфигурация
├── prometheus/              # Prometheus конфигурация
├── exporters/               # Custom exporters
└── examples/                # Примеры использования
```

## Testing

### Локальное тестирование

1. **Тестирование скриптов**:
   ```bash
   bash -n scripts/install/ubuntu-install.sh
   ```

2. **Тестирование Docker Compose**:
   ```bash
   docker compose -f docker/docker-compose.yml config
   docker compose -f docker/docker-compose.yml up -d
   # Проверить работу
   docker compose -f docker/docker-compose.yml down
   ```

3. **Тестирование Ansible**:
   ```bash
   ansible-playbook ansible/playbook.yml --syntax-check
   ansible-playbook ansible/playbook.yml --check
   ```

### CI/CD

GitHub Actions автоматически запускает тесты при каждом PR.

## Code Review

Все PR проходят code review. Обратите внимание на:

- Соответствие coding guidelines
- Наличие тестов (где применимо)
- Обновление документации
- Понятные commit messages

## Community

- Обсуждения: [GitHub Discussions](https://github.com/ranas-mukminov/Grafana-Setup-for-Linux/discussions)
- Telegram: [@runas_daemon](https://t.me/runas_daemon)
- Blog: [run-as-daemon.ru](https://run-as-daemon.ru)

## License

Внося вклад, вы соглашаетесь, что ваш код будет под MIT License.

## Questions?

Если у вас есть вопросы:
1. Проверьте [документацию](docs/)
2. Посмотрите существующие [issues](https://github.com/ranas-mukminov/Grafana-Setup-for-Linux/issues)
3. Задайте вопрос в [Discussions](https://github.com/ranas-mukminov/Grafana-Setup-for-Linux/discussions)
4. Напишите мне в [Telegram](https://t.me/runas_daemon)

---

**Спасибо за ваш вклад! 🙏**
