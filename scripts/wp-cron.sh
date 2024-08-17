#!/bin/bash

# Define constants
HOSTNAME=$(hostname)
LOG_FILE="/var/log/cron-docker-refresher.log"
CONFIG_FILE="/usr/local/scripts/config.txt"
TIMEOUT=10

# Create log file if it doesn't exist
touch $LOG_FILE

# Function to log entry
log_entry() {
  local job_name=$1
  local status=$2
  local message=$3
  local exit_code=$4
  local start_time=$5

  local end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local duration=$(date -u -d @$(( $(date -u -d "$end_time" +"%s") - $(date -u -d "$start_time" +"%s") )) +"%H:%M:%S")

  # Escape message and remove newlines, replacing them with spaces
  local escaped_message=$(echo "$message" | tr -d '\n' | tr -d '\r' | sed 's/"/\\"/g')

  local log_entry=$(cat <<EOF
{"timestamp": "$start_time","job_name": "$job_name","status": "$status","duration": "$duration","message": "$escaped_message","host": "$HOSTNAME","exit_code": $exit_code}
EOF
)

  # Use flock to ensure atomic write to log file
  {
    flock -x 200
    echo "$log_entry" >> "$LOG_FILE"
  } 200>> "$LOG_FILE"
}

# Function to run a task for a given URL
run_task() {
  local job_name=$1
  local url=$2
  local start_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

  # Log start of job
  {
    flock -x 200
    echo "$(date -u): Starting job $job_name for $url" >> "$LOG_FILE"
  } 200>> "$LOG_FILE"

  # Run the task and capture HTTP status code with a timeout
  local response task_output http_status
  response=$(curl -m $TIMEOUT -s -w "%{http_code}" -o >(cat) "$url")
  http_status=${response: -3}
  task_output=${response::-3}
  task_exit_code=$?

  # Append job name and host to the message if the task fails
  if [ $task_exit_code -ne 0 ] || [ "$http_status" -ge 400 ]; then
    task_output="Task for $job_name on $HOSTNAME failed with message: $task_output"
    log_entry "$job_name" "failure" "$task_output" $task_exit_code "$start_time"
    return
  fi

  # Ensure task_output is not empty for the success case
  if [ -z "$task_output" ]; then
    task_output="Task for $job_name on $HOSTNAME executed successfully with no output."
  fi

  log_entry "$job_name" "success" "$task_output" 0 "$start_time"
}

# Read configuration file and run tasks sequentially
while IFS=, read -r job_name url; do
  if [[ $job_name == \#* || -z $job_name || -z $url ]]; then
    continue
  fi
  run_task "$job_name" "$url"
done < "$CONFIG_FILE"

