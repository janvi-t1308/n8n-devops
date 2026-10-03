#! /bin/bash

set -euo pipefail

readonly SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
readonly PROJECT_DIR=$(dirname "$SCRIPT_DIR")

if [ ! -f "${PROJECT_DIR}/.env" ]; then
    echo "[ERROR] - .env file not found."
    exit 1
fi

set -a
source "${PROJECT_DIR}/.env"
set +a

readonly CANDIDATE_COMPOSE="${PROJECT_DIR}/deploy/docker-compose.yml"
readonly RUNTIME_DIR="${PROJECT_DIR}/runtime"
readonly BACKUP_DIR="${RUNTIME_DIR}/backup"
readonly COMPOSE_BACKUP_DIR="${BACKUP_DIR}/compose-backup"
readonly APP_BACKUP_DIR="${BACKUP_DIR}/app-backup"
readonly DB_BACKUP_DIR="${BACKUP_DIR}/db-backup"
readonly RUNTIME_COMPOSE="${RUNTIME_DIR}/docker-compose.yml"
readonly VALIDATE_COMPOSE="${SCRIPT_DIR}/validate-compose.sh"
readonly BACKUP_COMPOSE="${SCRIPT_DIR}/backup-compose.sh"
readonly HEALTH_CHECK="${SCRIPT_DIR}/health-check.sh"
readonly ROLLBACK="${SCRIPT_DIR}/rollback.sh"