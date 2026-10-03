#!/bin/bash
# Responsibilities -
# Validate Docker Compose syntax.
# Ensure the deployment file is safe to deploy.
# Detect blocked changes (e.g., PostgreSQL major version change in the future).

set -euo pipefail

source "$(dirname "$0")/common.sh"

################################################################################################
#-----FUNCTIONS-----#
################################################################################################

validate_argument_count(){
    if [ $# -ne 0 ]; then 
        echo "[WARNING] - Usage: $0"
        exit 1
    fi
}


validate_docker_version(){
    if docker compose version > /dev/null 2>&1; then
        echo "[INFO] - Docker Found" 
    else
        echo "[ERROR] - Docker Compose not Found"
        exit 1
    fi
}


file_check(){
    if [ ! -f "$CANDIDATE_COMPOSE" ]; then
        echo "[ERROR] - COMPOSE FILE '$CANDIDATE_COMPOSE' DOES NOT EXIST."
        exit 1
    fi
}


compose_validation(){
    echo "Validating Compose file..."

    if docker compose -f "$CANDIDATE_COMPOSE" config > /dev/null 2>&1; then
        echo "[SUCCESS] - Compose Validation Completed Successfully"
    else 
        echo "[ERROR] - Validation failed"
        exit 1
    fi
}

################################################################################################
#-----MAIN-----#
################################################################################################

main (){ 

validate_argument_count "$@"

validate_docker_version

file_check

compose_validation

}

main "$@"