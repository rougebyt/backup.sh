#!/bin/bash
# =============================================================================
# backup.sh — Smart Incremental Backup with rsync + GPG + Email Alerts
# Author: Moibon Dereje
# GitHub: https://github.com/rougebyt/backup.sh
# License: MIT
# =============================================================================

set -euo pipefail

# === CONFIG ===
SOURCE=""           # the path to what to back up
DEST=""                 # Backup drive
LOG="/var/log/backup.log"          # Log file
ENCRYPT=true                       # Encrypt with GPG?
GPG_RECIPIENT="moibon@example.com" # GPG key
EMAIL_ALERT="moibon@example.com"   # Alert on failure
MAX_BACKUPS=7                      # Keep last N backups
# =============

# === COLORS ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"; }

die() { log "${RED}ERROR: $1${NC}"; send_alert "$1"; exit 1; }

send_alert() {
    if command -v mail >/dev/null; then
        echo "Backup failed: $1" | mail -s "Backup Failed" "$EMAIL_ALERT"
    fi
}

# === VALIDATION ===
[[ $UID -ne 0 ]] && die "Run as root (for rsync permissions)"
[[ -d "$SOURCE" ]] || die "Source $SOURCE not found"
[[ -d "$DEST" ]] || die "Destination $DEST not mounted"

# === BACKUP DIR ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="$DEST/backup_$TIMESTAMP"
mkdir -p "$BACKUP_DIR"

log "${GREEN}Starting backup: $SOURCE → $BACKUP_DIR${NC}"

# === RSYNC ===
rsync -aHAX --delete --info=progress2 \
      --link-dest="$DEST/latest" \
      "$SOURCE/" "$BACKUP_DIR/data/" >> "$LOG" 2>&1 || die "rsync failed"

# === ENCRYPT (optional) ===
if $ENCRYPT; then
    log "Encrypting backup..."
    tar -cz "$BACKUP_DIR/data" | gpg --encrypt --recipient "$GPG_RECIPIENT" > "$BACKUP_DIR/data.tar.gz.gpg"
    rm -rf "$BACKUP_DIR/data"
    log "${GREEN}Encrypted to data.tar.gz.gpg${NC}"
fi

# === UPDATE LATEST LINK ===
rm -f "$DEST/latest"
ln -s "$BACKUP_DIR" "$DEST/latest"

# === CLEANUP OLD BACKUPS ===
mapfile -t OLD_BACKUPS < <(ls -d "$DEST"/backup_* 2>/dev/null | sort | head -n -"$MAX_BACKUPS")
for old in "${OLD_BACKUPS[@]}"; do
    log "Removing old backup: $old"
    rm -rf "$old"
done

log "${GREEN}Backup completed successfully!${NC}"
exit 0

# === DRY RUN ===
if [[ "${1:-}" == "--dry-run" ]]; then
    log "${YELLOW}DRY RUN MODE${NC}"
    rsync -aHAX --delete --info=progress2 --dry-run \
          --link-dest="$DEST/latest" \
          "$SOURCE/" "$BACKUP_DIR/data/"
    exit 0
fi