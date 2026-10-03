#! /bin/bash

# Responsibilities
# 1. Timestamp backup
# 2. Retain latest 5 backup
# 3. cleanup old backups

set -euo pipefail

readonly TIMESTAMP_FORMAT="%Y%m%d-%H%M%S"
readonly TIMESTAMP=$(date + "$TIMESTAMP_FORMAT")
readonly MAX_BACKUPS=5

source "$(dirname "$0")/common.sh"

validate_argument(){
    if [ $# -ne 0 ]; then
        echo "[ERROR] - USAGE: $0 "
        exit 1
    fi
}

verify_backup_folder(){
    echo "[INFO] - Checking data backup directories."
    
    mkdir -p "${DB_BACKUP_DIR}"
    mkdir -p "${APP_BACKUP_DIR}"

    echo "[INFO] - Backup Directories verified."
}

db_backup_creation(){
    local DB_CONTAINER=$( docker compose -f "${RUNTIME_COMPOSE}" ps -q n8n-db )

    if [ -z "$DB_CONTAINER" ]; then
        echo "[ERROR] - DB container not running."
        exit 1
    fi
    
    echo "[INFO] - creating postgres database backup"

    local DB_BACKUP="${DB_BACKUP_DIR}/db_backup_${TIMESTAMP}.sql.gz"

    docker exec "$DB_CONTAINER" pg_dump --clean --if-exists -U "$DB_POSTGRESDB_USER" -d "$DB_POSTGRESDB_DATABASE" | gzip > "$DB_BACKUP"

    if [ ! -s "$DB_BACKUP" ]; then
        echo "[ERROR] - DB Backup not created."
        exit 1
    fi

    echo "[INFO] - DB backup ready. '$DB_BACKUP'"
}

app_backup_creation(){

    echo "[INFO] - creating n8n app volume backup."

    local APP_BACKUP="${APP_BACKUP_DIR}/n8n-app-vol-backup_${TIMESTAMP}.tar.gz"

    docker run --rm \
    -v n8n-devops-project_n8n-data:/data \
    -v "${APP_BACKUP_DIR}:/backup" \
    alpine:3.22 \
    tar -czf "/backup/n8n-app-vol-backup_${TIMESTAMP}.tar.gz" -C /data .

    if [ ! -s "$APP_BACKUP" ]; then
        echo "[ERROR] - APP backup not created."
        exit 1
    fi

    echo "[INFO] - App backup ready. '$APP_BACKUP'"
}

cleanup_old_backups() {

    local DB_BACKUP_FILES=$(find "${DB_BACKUP_DIR}" -maxdepth 1 -type f -name "*.sql.gz" | wc -l) 

    if [ "$MAX_BACKUPS" -lt "$DB_BACKUP_FILES" ]; then
        local DB_BACKUPS_TO_BE_DELETED=$(( DB_BACKUP_FILES - MAX_BACKUPS ))
        echo "[INFO] - Number of file to be deleted ${DB_BACKUPS_TO_BE_DELETED}"
        find "${DB_BACKUP_DIR}" -maxdepth 1 -type f -name "*.sql.gz" | sort | head -n ${DB_BACKUPS_TO_BE_DELETED} | xargs rm -f
    fi

    local APP_BACKUP_FILES=$(find "${APP_BACKUP_DIR}" -maxdepth 1 -type f -name "*.tar.gz" | wc -l) 

    if [ "$MAX_BACKUPS" -lt "$APP_BACKUP_FILES" ]; then
        local APP_BACKUPS_TO_BE_DELETED=$(( APP_BACKUP_FILES - MAX_BACKUPS ))
        echo "[INFO] - Number of file to be deleted ${APP_BACKUPS_TO_BE_DELETED}"
        find "${APP_BACKUP_DIR}" -maxdepth 1 -type f -name "*.tar.gz" | sort | head -n ${APP_BACKUPS_TO_BE_DELETED} | xargs rm -f
    fi

    echo "[INFO] - Cleanup completed."
}


main (){

    echo "[WARNIN] - This operation would overwrite the current database and application data"

    validate_argument "$@"

    verify_backup_folder

    db_backup_creation

    app_backup_creation

    cleanup_old_backups

    echo "[SUCCESS] - Backup completed successfully."

}

main "$@"