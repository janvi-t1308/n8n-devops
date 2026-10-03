#!/bin/bash

# Responsibilities
# 1. Restore previous compose
# 2. Redeploy
# 3. Verify rollback succeeded

set -euo pipefail

source "$(dirname "$0")/common.sh"

validate_argument_count(){

    if [ $# -ne 0 ]; then
        echo "[ERROR] - Usage: $0"
        exit 1
    fi
}

restore_previous_compose(){
    echo "[INFO] - validating backup directory"

    if [ ! -d "$COMPOSE_BACKUP_DIR" ]; then
        echo "[ERROR] - '$COMPOSE_BACKUP_DIR' directory not found"
        exit 1
    fi

    echo "[INFO] - Found '$COMPOSE_BACKUP_DIR' directory"

    PREVIOUS_COMPOSE=$(find "$COMPOSE_BACKUP_DIR" -type f -name "docker-compose*.yml" | sort | tail -n 1)

    if [ -z "$PREVIOUS_COMPOSE" ]; then
        echo "[ERROR] - no backup found"
        exit 1
    fi

    echo "[INFO] - $(basename "$PREVIOUS_COMPOSE") found"

}

deploy_previous_compose_version() {

    echo "[INFO] - Restoring $(basename "$PREVIOUS_COMPOSE")"

    cp "$PREVIOUS_COMPOSE" "${RUNTIME_COMPOSE}"

    echo "[INFO] - Previous docker compose restored in the runtime dir"

    docker compose -f "${RUNTIME_COMPOSE}" pull

    docker compose -f "${RUNTIME_COMPOSE}" up -d

}


main (){


    echo "[WARNING] - Deployment failed, starting automatic rollback"

    validate_argument_count "$@"

    restore_previous_compose

    deploy_previous_compose_version

    if "$SCRIPT_DIR/health-check.sh" ; then
        echo "[SUCCESS] - Rollback completed successfully"
    else
        echo "[ERROR] - Rollback failed"
        exit 1
    fi
}

main "$@"