
<h1 align="center">backup.sh</h1>

<p align="center">
  <strong>Smart Incremental Backup with rsync + GPG + Alerts</strong><br>
  <i>Hard links, encryption, cleanup, email on failure</i>
</p>

<p align="center">
  <a href="#installation">Install</a> •
  <a href="#usage">Usage</a> •
  <a href="#features">Features</a> •
  <a href="#cron">Cron</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/language-Bash-89E051?logo=gnu-bash&logoColor=white" />
  <img src="https://img.shields.io/badge/platform-Linux-blue" />
  <img src="https://github.com/rougebyt/backup.sh/actions/workflows/ci.yml/badge.svg" />
</p>

---

## Why This Exists

`rsync` is powerful. Most backup scripts are fragile.  
`backup.sh` is **robust and secure**.

---

## Features

| Feature | Status |
|-------|--------|
| Incremental (hard links) | Done |
| GPG encryption | Done |
| Auto-cleanup | Done |
| Email alerts | Done |
| Logging | Done |
| CI-tested | Done |
| Docker-ready | Done |

---

## Installation

```bash
git clone https://github.com/rougebyt/backup.sh.git
cd backup.sh
sudo cp backup.sh /usr/local/bin/backup
sudo chmod +x /usr/local/bin/backup
```

---

## Usage

```bash
# Dry run
sudo backup --dry-run

# Full backup (edit config in script)
sudo backup
```

### Config (edit in script)

```bash
SOURCE="/home/user/docs"
DEST="/mnt/backup"
ENCRYPT=true
GPG_RECIPIENT="you@example.com"
EMAIL_ALERT="you@example.com"
MAX_BACKUPS=7
```

---

## Cron Setup

```bash
sudo crontab -e
```

Add:

```cron
0 2 * * * /usr/local/bin/backup >> /var/log/backup_cron.log 2>&1
```

---

## Docker (Test Locally)

```dockerfile
FROM alpine:latest
RUN apk add --no-cache rsync bash coreutils gnupg
COPY backup.sh /backup.sh
CMD ["/bin/sh", "/backup.sh"]
```

---

## Project Structure

```
backup.sh         → Main script
README.md         → This file
.docker/          → Docker test
.github/          → CI
LICENSE
```

---

## Contributing

1. Fork
2. Branch (`feature/alerts`)
3. Commit
4. PR

---

## Author

**Moibon Dereje**  
- GitHub: [@rougebyt](https://github.com/rougebyt)  
- X: [@rougebyt](https://x.com/rougebyt)

---

## License

MIT © Moibon Dereje
