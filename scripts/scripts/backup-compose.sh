#!/bin/bash
# Responsibilities
# 1. Timestamp backup
# 2. Retain latest 5 backup
# 3. cleanup old backups

set -euo pipefail

readonly Timestamp_Format="%Y%m%d-%H%M%S"
readonly Max_Backup=5

source "$(dirname "$0")/common.sh"

################################################################################################
#-----FUNCTIONS-----#
################################################################################################

validate_argument_count(){
    if [ $# -ne 0 ]; then
        echo "[ERROR] - Usage: $0"
        exit 1
    fi
}

file_check(){
    if [ ! -f "$RUNTIME_COMPOSE" ]; then
        echo "[ERROR] - Compose file "$RUNTIME_COMPOSE" does not exist."
        exit 1
    fi
}

create_backup_directory(){
    echo "[INFO] - Checking backup directory..."
    mkdir -p "$COMPOSE_BACKUP_DIR"
    echo "[SUCCESS] -  Compose backup directory is ready."
}

create_backup(){
    echo "[INFO] - Creating Backup"
    local timestamp=$(date +"$Timestamp_Format")
    cp "$RUNTIME_COMPOSE" "$COMPOSE_BACKUP_DIR/docker-compose-$timestamp.yml"
    echo "[SUCCESS] - Docker compose backup created successfully"
}

delete_old_backup(){
    local total_backup_files=$(find "$COMPOSE_BACKUP_DIR" -name "docker-compose-*.yml" -type f | wc -l)

    if [ "$total_backup_files" -le "$Max_Backup" ]; then
        echo "[INFO] - no backup files required to be deleted"
        return
    fi 

    local files_to_delete=$((total_backup_files - Max_Backup))

    echo "[INFO] - Deleting old backups"
    find "$COMPOSE_BACKUP_DIR" -name "docker-compose-*.yml" -type f | sort | head -n "$files_to_delete" | xargs -r rm -f
    echo "[SUCCESS] - Old Backups Removed"

}

################################################################################################
#-----MAIN-----#
################################################################################################

main () {

validate_argument_count "$@"

file_check

create_backup_directory

create_backup

delete_old_backup

echo "[SUCCESS] - Backup process completed successfully"

}

main "$@"