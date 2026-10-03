#! /bin/bash

#Resposibilities -
#ensure the app container is stopped before db and app restoration
#ensure db container is up
#restore the database and app backup
#verify both app and db restoration
#validate the restoration

set -euo pipefail

source "$(dirname "$0")/common.sh"

validate_argument_count(){
    if [ $# -ne 2 ]; then
        echo "[ERROR] - Usage: $0 <db-backup-file> <app-backup-file>"
        exit 1
    fi
}

verify_backup_files(){

    echo "[INFO] - Verifying db-backup file."

    if [ ! -s "${DB_BACKUP_DIR}/${DB_BACKUP_FILE}" ]; then
        echo "[ERROR] - db backup not found."
        exit 1
    fi

    echo "[INFO] - db backup verified successfully."
    echo "[INFO] -  verifying app-backup file."

    if [ ! -s "${APP_BACKUP_DIR}/${APP_BACKUP_FILE}" ]; then
        echo "[ERROR] - app backup not found."
        exit 1
    fi
    
    echo "[INFO] - app backup verified successfully."

}

prepare_restore() {
    
    echo "[WARNING] - Restore operation will overwrite the current database and application data"

    echo "[INFO] - Stopping app container."

    docker compose -f "$RUNTIME_COMPOSE" stop n8n-app

    echo "[INFO] - Ensuring db container is running."

    docker compose -f "$RUNTIME_COMPOSE" up -d n8n-db

}

restore_db_backup(){

    echo "[INFO] - Restoring Postgresql database."

    local db_container_id=$( docker compose -f "${RUNTIME_COMPOSE}" ps -q n8n-db )

    if [ -z "$db_container_id" ]; then
        echo "[ERROR] -  db container is not running"
        exit 1
    fi

    gunzip -c "${DB_COMPOSE_DIR}/${DB_BACKUP_FILE}" | \
    docker exec -i "$db_container_id" psql -U "$DB_POSTGRESDB_USER" -d "$DB_POSTGRESDB_DATABASE"

    echo "[INFO] - Verifying restored database"

    docker exec "$db_container_id" \
    psql -U "$DB_POSTGRESDB_USER" \
    -d "$DB_POSTGRESDB_DATABASE" \
    -c "select count(*) from workflow_entity;" > /dev/null

    echo "[SUCCESS] - DB backup restored successfully."

}

restore_app_backup(){

    echo "[INFO] - Restoring app volume."
    
    docker run --rm \
    -v n8n-devops-project_n8n-data:/data \
    -v "${APP_BACKUP_DIR}":/backup \
    alpine:3.22 \
    sh -c "rm -rf /data/* && tar -xzf /backup/${APP_BACKUP_FILE} -C /data"

    echo "[INFO] - Verifying the app data restore."

    docker run --rm \
    -v n8n-devops-project_n8n-data:/data \
    alpine:3.22 \
    sh -c "test \"\$(ls -A /data)\""

    echo "[SUCCESS] - app backup restored successfully."

}

start_application(){

    echo "[INFO] - Starting application"

    docker compose -f "$RUNTIME_COMPOSE" up -d n8n-app

}

verify_restore(){

    echo "[INFO] - Running application health check."

    "${HEALTH-CHECK}"

    echo "[SUCCESS] - Restore verification completed."

}

main (){

validate_argument_count "$@"

DB_BACKUP_FILE="$1"
APP_BACKUP_FILE="$2"

verify_backup_files

prepare_restore

restore_db_backup

restore_app_backup

start_application

verify_restore

echo "[SUCCESS] - Database and Application restored successfully."

}

main "$@"