# GitHub Copilot Instructions for `Grafana-Setup-for-Linux`

You are working **inside the repository `ranas-mukminov/Grafana-Setup-for-Linux`**, acting as a **Senior DevSecOps / Security Engineer**.

This repo contains **step-by-step guides and scripts to install and configure Grafana on Linux**:
- native installation scripts for multiple distros (Ubuntu, Debian, RHEL, Rocky, Alma, Arch, openSUSE),
- Docker / docker-compose stack,
- Kubernetes Helm values,
- Ansible playbooks,
- exporters and helper scripts.

**Key requirement: documentation is bilingual** – English (`README.md`) and Russian (`README.ru.md`) – and both must stay aligned.

## Core goals

When editing this repo, always aim to:

1. **Maintain bilingual documentation** - `README.md` and `README.ru.md` must stay synchronized in structure and content.
2. Keep **installation scripts** idempotent, reproducible and safe for production-like servers.
3. Keep **containerized stack** (Docker/Podman/Helm) secure by default:
   - proper volumes,
   - no hardcoded secrets,
   - sane resource limits.
4. Keep **documentation** up to date for current Grafana (≥11/12) and Linux LTS versions.
5. Keep **CI workflows** fast and useful:
   - linting (shell, YAML, Docker),
   - basic smoke tests of docker-compose.

Prefer:
- explicit configuration over hidden defaults,
- security and observability over convenience when in doubt,
- clear technical meaning in translations over "literary" style.

---

## 0. Repository context and scope

### Target environment
- **OS**: Modern LTS Linux distros (Ubuntu / Debian 11+ / RHEL / Rocky / Alma 9+ / Arch rolling / openSUSE Leap 15.5+)
- **Grafana**: Current stable (12.x+), installed from official repos
- **Purpose**: Practical setup guide with copy-paste ready commands and minimal scripts

This repo is **not** a full automation framework. Avoid:
- Heavy abstractions (no huge Ansible roles; keep playbooks focused)
- Copying long chunks from external docs; summarize and link to [Grafana official docs](https://grafana.com/docs/grafana/latest/setup-grafana/)

### Version references
When mentioning versions:
- For Grafana: use "Grafana ≥ 11/12 (current stable)" and link to official [installation docs](https://grafana.com/docs/grafana/latest/setup-grafana/installation/)
- For OS: focus on currently supported LTS releases
- Avoid hard-coding EOL versions unless explicitly marked as legacy
- Add time-sensitive notes: `Last verified: <month> <year>` in both READMEs

---

## 1. Bilingual README rules (CRITICAL)

There are always **two main docs**:
- `README.md` – English
- `README.ru.md` – Russian

When you change documentation, you **MUST**:

1. **Keep the section structure identical**:
   - Same headings hierarchy (##, ###, etc.)
   - Same order of sections
   - Same number of sections
2. When adding/removing a section in one language, **mirror it** in the other
3. Keep all **commands, file paths and config snippets byte-identical** between languages (only comments / prose are translated)
4. When updating versions (Grafana, OS, etc.) – update in **BOTH** READMEs
5. Keep code blocks with language hints: `bash`, `ini`, `nginx`, `yaml`

**Translation guidelines:**
- Use short, neutral Russian for tech parts (e.g. "Установите Grafana из официального репозитория")
- Do not translate: commands, file names, package names, service names
- Prefer clear technical meaning over literary style
- Use numbered lists for step-by-step instructions
- Prefer small sections rather than huge walls of text

**Never leave one README updated and the other outdated.**

---

## 2. What you should do first in this repo

When working here, you should automatically converge towards the following baseline state
and propose **clean, focused pull requests** for @ranas-mukminov:

1. Ensure `.github/copilot-instructions.md` exists and is up to date
2. **Ensure README.md and README.ru.md are perfectly synchronized**:
   - Same structure and section order
   - Same commands and code blocks (only prose is translated)
   - Same version numbers and links
3. Ensure our key components have basic quality checks:
   - `scripts/install/*.sh` are linted with `shellcheck` in CI
   - `docker/*.yml` are linted with `yamllint` or similar
   - Dockerfiles (if any) are checked with `hadolint`
4. Ensure `docker/` stack is:
   - using `.env` for secrets
   - using named volumes for data
   - using non-root containers where possible
   - exposing only needed ports
5. Ensure `kubernetes/helm/values.yaml`:
   - disables anonymous access
   - sets admin credentials via existing values (not hardcoded)
   - enables persistent storage where appropriate
   - has comments about ingress/TLS security
6. Keep changes grouped per topic:
   - do not mix installer fixes, docs and CI changes in one random commit

---

## 3. General coding rules

For scripts and configs:

- Shell scripts: POSIX sh-compatible when possible, or clearly marked as bash
- Avoid functions that modify global state implicitly; keep things explicit
- Add **short comments about WHY**, not obvious WHAT
- Keep distro-specific logic in separate functions or files:
  - `ubuntu-install.sh`
  - `centos-install.sh`
  - `suse-install.sh`
  - `arch-install.sh`
- Do not introduce new languages or tools without a short justification comment

Naming:

- scripts: `snake_case.sh`
- env vars: `UPPER_SNAKE_CASE`
- Ansible: use clear role names and variables

---

## 4. Install scripts (`scripts/install/*`)

When editing or generating install scripts:

1. Make them **idempotent** where possible:
   - check if a package is already installed before installing
   - avoid re-importing keys or repos blindly if it creates duplicates
2. Always:
   - set correct file and directory permissions for Grafana, Prometheus, Loki, etc.
   - avoid world-writable dirs
   - ensure log directories exist with safe permissions
3. Support both:
   - fresh install
   - "configure only" mode if appropriate (flag or env)
4. Add clear error handling:
   - exit non-zero on critical failure
   - print a short helpful message
5. Reference official Grafana installation docs for each distro:
   - [Debian/Ubuntu](https://grafana.com/docs/grafana/latest/setup-grafana/installation/debian/)
   - [RHEL/CentOS/Rocky](https://grafana.com/docs/grafana/latest/setup-grafana/installation/rpm/)

Do not:
- embed plain-text admin passwords or tokens
- assume root without checking (`id -u`)
- use deprecated commands (e.g., `apt-key`) without migration notes

---

## 5. Docker / docker-compose (`docker/`)

When editing or generating docker-related files:

1. **Security defaults**
   - All credentials must be loaded from `.env` or secrets, not hardcoded
   - Default example `.env.example` must NOT contain real secrets
   - Volumes for Grafana, Prometheus, Loki and databases must be named, not anonymous

2. **Resource limits**
   - Where sensible, propose `deploy.resources.limits` and `reservations` for services
   - Add comments that these are examples and should be tuned per environment

3. **Networking**
   - Use dedicated user-defined networks instead of the default bridge
   - Avoid exposing ports directly to 0.0.0.0 if not required
   - Document which ports MUST be exposed and why

4. **Images**
   - Prefer official images (grafana/grafana, prom/prometheus, grafana/loki, etc.)
   - Pin to at least a major.minor version (`11.x`, `12.x`) where possible to avoid surprises
   - Add comments about upgrade procedure (use `make update` if available)

5. **Makefile integration**
   - Ensure `make start/stop/status/logs/backup/restore/update/test` targets are in sync with docker-compose files
   - Do not break existing targets

---

## 6. Kubernetes / Helm (`kubernetes/helm`)

When editing `values.yaml` or adding manifests:

1. Enforce:
   - admin credentials via values, not hardcoded
   - persistence enabled by default (PVCs)
   - `securityContext` blocks with non-root UID/GID where the chart supports it

2. Ingress / TLS:
   - prefer enabling TLS termination at ingress
   - avoid examples with plain HTTP exposed publicly
   - add comments about using cert-manager or existing TLS

3. Resource requests/limits:
   - propose sensible default requests/limits for Grafana and Prometheus
   - mention that these should be tuned for production

4. Multi-tenancy and auth:
   - if you touch auth-related values, ensure anonymous access is disabled by default
   - note LDAP / OAuth2 integration only as commented examples

---

## 7. Ansible (`ansible/`)

When editing playbooks:

1. Idempotency:
   - use proper `state=present/absent`
   - avoid `shell` when modules exist

2. Security:
   - ensure file permissions are explicit
   - no plain-text passwords in playbooks; use vars or vault

3. Inventory:
   - keep production vs lab inventories clearly separated

---

## 8. CI (`.github/workflows/`)

When creating or modifying CI workflows:

1. Linting:
   - add jobs for:
     - `shellcheck` on `scripts/**/*.sh`
     - `yamllint` on `docker/*.yml` and `kubernetes/**/*.yaml`
     - `hadolint` on Dockerfiles (if present)
2. Smoke tests:
   - add a job that:
     - runs docker-compose up in CI in a minimal mode
     - checks that Grafana responds on `localhost:3000` (or inside a test network)
     - tears down containers after

3. Best practices:
   - pin GitHub Actions versions (`@vX`)
   - use caching only where safe and helpful
   - keep workflows readable and small

---

## 9. Documentation (README.md / README.ru.md / docs/)

### Priority 1: Bilingual README alignment

**CRITICAL**: Keep **English and Russian READMEs perfectly synchronized** in structure and content.

1. **Structure alignment**:
   - Same section headings (##, ###) in the same order
   - Same number of sections and subsections
   - Same visual elements (badges, dividers, ASCII diagrams)

2. **Content alignment**:
   - Quick Start commands actually work with the current repo layout
   - Supported distributions and versions match `scripts/install/*`
   - All referenced files (docs pages, scripts) exist
   - Version numbers are identical in both files

3. **Code blocks**:
   - Must be complete and copy-paste-ready
   - Must be byte-identical between English and Russian READMEs
   - Avoid truncated snippets
   - Include language hints: `bash`, `ini`, `nginx`, `yaml`, `python`

4. **Links**:
   - When citing external instructions, link to [official Grafana docs](https://grafana.com/docs/grafana/latest/) instead of duplicating whole manuals
   - Ensure internal links (to `docs/`, `scripts/`, etc.) work in both READMEs

### Priority 2: Documentation quality and scope

You may improve or add:

- **Project overview**: Short description of what the repo provides
- **Supported OS / Grafana matrix**: Clear table of tested versions
- **Step-by-step install sections**:
  - Debian/Ubuntu (22.04, 24.04)
  - RHEL/Rocky/Alma (9.x)
  - Arch Linux (rolling)
  - openSUSE Leap (15.5+)
- **Post-install**:
  - Starting service (`systemctl start grafana-server`)
  - Enabling autostart (`systemctl enable grafana-server`)
  - Default credentials and URL
- **Update / Upgrade** and **Uninstall** sections, referencing official docs
- **Quick start blocks** with minimal commands

Keep docs focused on:
- Installing Grafana on a bare Linux server
- Optional: basic Nginx reverse proxy and firewall notes
- Containerized deployments (Docker, Podman, Kubernetes)

### Priority 3: Security best practices

Always include **Security Best Practices** sections:
- Change default admin password immediately
- Restrict Grafana/Prometheus access to internal networks or via VPN
- Enable TLS for external access
- Configure backups for data
- Use `.env` files for secrets, not hardcoded values

### Style guidelines

**English README:**
- Concise, imperative style: "Run this command…", "Edit this file…"
- Use fenced code blocks with language hints
- No marketing language

**Russian README:**
- Короткие, прямые фразы
- Не переводить команды и имена файлов
- Тот же порядок блоков кода, что и в английской версии
- Технические термины: использовать общепринятые (например, "мониторинг", "дашборд", "стек")

Both:
- Use numbered lists for step-by-step instructions
- Prefer small sections rather than huge walls of text
- Add timestamps for time-sensitive content: `Last verified: November 2024`

---

## 10. Feature extension and other container runtimes (separate PR)

When requested to **add new features or support additional container runtimes**, prepare a
**separate, focused pull request**.

Scope of such PR may include:

1. Adding **Podman** variants for existing Docker workflows:
   - `docker/` examples that work with `podman-compose`
   - notes on rootless vs rootful modes
   - explicit comments about volume paths and SELinux considerations

2. Adding **rootless setups** where possible:
   - for docker/Podman stacks
   - for systemd user services

3. Adding **Nomad or other runtimes**:
   - examples under `examples/nomad/*.hcl`
   - clearly marked as examples, not production defaults
   - explicit `privileged` and network settings with comments about risks

4. Adding **extra exporters or dashboards**:
   - new exporter containers or scripts under `exporters/`
   - new dashboard JSONs under `grafana/` with import instructions

Constraints:

- Do not change the core install behaviour in the same PR
- Keep new runtimes under `examples/` or clearly separated directories
- Add minimal but clear doc updates that link to the new examples

---

## 11. Validation checklist

Before proposing changes, ensure:

- [ ] `README.md` и `README.ru.md` имеют одинаковую структуру
- [ ] Все команды проверены логически (реальные пакеты / сервисы)
- [ ] Ссылки на документацию Grafana ведут на актуальные разделы
- [ ] Примеры systemd / nginx синтаксически корректны
- [ ] Нет упоминаний устаревших команд (`apt-key`, старые репозитории) без примечаний
- [ ] Скрипты прошли `shellcheck` (или запланированы для добавления в CI)
- [ ] Docker compose файлы прошли `yamllint` (или запланированы для добавления в CI)
- [ ] Секреты вынесены в `.env`, а не захардкожены
- [ ] Volumes в docker-compose именованные, не анонимные
- [ ] В Kubernetes values используются переменные для паролей, не константы

Если в чём-то не уверены, добавьте короткое примечание "Note / Примечание" вместо придумывания поведения.

---

## 12. Pull request style

When preparing changes with the intent to open a PR:

1. Keep PRs small and focused:
   - one concern per PR (e.g. "CI + linting" or "Podman examples", not everything at once)

2. Use clear titles, for example:
   - `Improve CI: add shellcheck and docker-compose smoke tests`
   - `Add Podman and rootless examples for Grafana stack`
   - `Update bilingual README for Grafana 12.x`

3. PR description must list:
   - what was changed
   - how to test it (`make test`, `make start`, etc.)
   - any breaking changes (ideally none)

4. Commits should be logically grouped:
   - docs
   - scripts/configs
   - CI

5. When unsure between convenience and security, choose **security** and add a short comment like:
   - `# NOTE: Grafana should not be exposed directly to the internet without TLS and auth.`

### Git workflow example

```bash
# Create a feature branch from the default branch
git checkout -b docs/grafana-setup-bilingual-update

# Make changes to both READMEs and any scripts/configs
# Edit: README.md, README.ru.md, and other files

# Stage and commit
git add README.md README.ru.md
git commit -m "Update bilingual Grafana setup guides"

# Push and open PR
git push origin docs/grafana-setup-bilingual-update
```

### PR body template

```markdown
## Summary
- What changed in English README
- What changed in Russian README
- Any new scripts / configs

## Testing
- Commands logically verified against current Grafana docs
- systemd/nginx snippets checked for syntax issues

## Notes
- Any OS / version assumptions
- Links to related issues or documentation
```

Do not merge the PR automatically; leave it for @ranas-mukminov to review.

---

## 13. Copilot Chat behaviour

When asked to "update docs" or "add section X" for this repo:

1. **First, output a short plan**:
   - which sections to touch
   - what you will add/remove in both READMEs

2. **Then show the changes**:
   - Full updated contents or minimal diffs for both `README.md` and `README.ru.md`
   - Keep them structurally identical

3. **Finally, suggest**:
   - branch name
   - commit message
   - PR title and short body

**Always remember: no change in English README without a mirrored change in Russian README.**
