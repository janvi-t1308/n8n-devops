#!/bin/bash
# Responsibilities
# 1. Wait for containers
# 2. Check container health
# 3. Check HTTP response
# 4. Retry intelligently before failing

################################################################
#CONSTANTS
################################################################

set -euo pipefail

readonly CONTAINER_SUCCESS_STATUS="running"
readonly MAX_WAIT_TIME=20
readonly MAX_RETRIES=10

source "$(dirname "$0")/common.sh"

################################################################
#FUNCTIONS
################################################################

validate_argument_count(){

    if [ $# -ne 0 ]; then
        echo "[WARNING] - Usage: $0"
        exit 1
    fi
}


check_container_status(){

    for ((attempt=1; attempt <= "$MAX_RETRIES"; attempt++)); do
        echo "[INFO] - checking container status attempt '$attempt'..."

        app_container_status=$(docker compose -f "${RUNTIME_COMPOSE}" ps n8n-app --format "{{.State}}")
        db_container_status=$(docker compose -f "${RUNTIME_COMPOSE}" ps n8n-db --format "{{.State}}")

        echo "[INFO] - App container status: $app_container_status"
        echo "[INFO] - DB container status: $db_container_status"

        if [[ "$app_container_status" == "$CONTAINER_SUCCESS_STATUS" && "$db_container_status" == "$CONTAINER_SUCCESS_STATUS" ]]; then
            echo "[SUCCESS] - App and DB containers are running"
            return
        fi

        if [ "$attempt" -lt "$MAX_RETRIES" ]; then
            echo "[INFO] - Retrying in '$MAX_WAIT_TIME's..."
            sleep "$MAX_WAIT_TIME"
        fi

    done

    echo "[FAILURE] - Containers fails to reach the running state after '$MAX_RETRIES' attempts!" 
    exit 1
}

check_health(){

    echo "[INFO] - Checking app health..."
    
    for (( attempt=1; attempt <= "$MAX_RETRIES"; attempt++ )); do

        echo "[INFO] - '$attempt' attempt to check app health"

        http_status=$(curl -s -o /dev/null -w "%{http_code}"  "$APP_URL" || echo "000")

        if [ "$http_status" -eq 200 ]; then
            echo "[SUCCESS] - app working correctly"
            return
        fi 

        if [ "$attempt" -lt "$MAX_RETRIES" ]; then
            echo "[ERROR] - HTTP status - '$http_status', retrying in '$MAX_WAIT_TIME's..."
            sleep "$MAX_WAIT_TIME"
        fi

    done

    echo "[FAILURE] - Application health check failed, application not running!"
    exit 1
}


main() {

    validate_argument_count "$@"

    check_container_status

    check_health

    echo "[SUCCESS] - Health check completed successfully"

}

main "$@"