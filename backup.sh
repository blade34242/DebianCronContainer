#!/bin/bash

# Example backup script
echo "Starting backup: $(date)"

# Perform backup tasks (e.g., database dump, file sync)
# Example commands
# mysqldump -u user -p password database > /backups/db_backup.sql
# rsync -a /data /backups/data

echo "Backup completed: $(date)"

