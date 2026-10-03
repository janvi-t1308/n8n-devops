#! /bin/bash

# validate the new docker-compose.yml
# backup the current docker-compose 
# replace current compose with the new compose
# docker compose pull
# docker compose up -d
# health check for both db and app
# rollback.sh (if deployment failed)

set -euo pipefail 

source "$(dirname "$0")/scripts/common.sh"

replace_old_compose(){

    echo "[INFO] - Replacing the old compose with the new compose in '$RUNTIME_DIR'"
    
    cp "$CANDIDATE_COMPOSE" "${RUNTIME_COMPOSE}"
    
    echo "[INFO] - Old compose replaced."

}

main () {

    "$VALIDATE_COMPOSE"

    "$BACKUP_COMPOSE" 

    replace_old_compose

    echo "[INFO] - Pulling latest image."

    docker compose -f "${RUNTIME_COMPOSE}" pull 

    echo "[INFO] - Starting Deployment."

    docker compose -f "${RUNTIME_COMPOSE}" up -d

    echo "[INFO] - Starting health check."

    if "$HEALTH_CHECK"; then

        echo "Deployment successfully completed."

    else 

        echo "Deployment failed. Starting rollback."

        if "$ROLLBACK"; then
            echo "[INFO] - Rollback completed successfully."
        fi

        echo "[ERROR] - Roll back failed. Deployment is stopped."
        exit 1

    fi

}

main 