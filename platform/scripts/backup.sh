#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Configuration
BACKUP_DIR="./backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p $BACKUP_DIR

# Load .env
source .env

echo "Starting backup: $TIMESTAMP"

# 1. Database Backup
echo "Backing up Postgres databases..."
docker exec platform-postgres pg_dumpall -U $POSTGRES_USER > $BACKUP_DIR/db_all_$TIMESTAMP.sql

# 2. Volume/Data Backups
echo "Backing up Authentik media..."
tar -czf $BACKUP_DIR/authentik_media_$TIMESTAMP.tar.gz authentik/media/ 2>/dev/null

echo "Backing up NocoBase storage..."
tar -czf $BACKUP_DIR/nocobase_storage_$TIMESTAMP.tar.gz nocobase/storage/ 2>/dev/null

# 3. Config Backup
echo "Backing up configs..."
tar -czf $BACKUP_DIR/config_$TIMESTAMP.tar.gz .env compose.shared.yml traefik/dynamic/ 2>/dev/null

echo "Backup completed: $BACKUP_DIR"
ls -lh $BACKUP_DIR/*$TIMESTAMP*
