#!/bin/bash

# Configuration
CHECK_INTERVAL=60  # Interval between checks in seconds
RETRY_COUNT=3      # Number of retries before marking the application as down
RETRY_INTERVAL=5   # Interval between retries in seconds
LOG_FILE="/var/log/app_uptime.log"
STATUS_FILE="/var/run/app_status"

# Colors for output
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

# Function to log messages
log_message() {
    local message="$1"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $message" | tee -a "$LOG_FILE"
}

# Function to check application status
check_app_status() {
    local retries=0
    local http_status

    while [ $retries -lt $RETRY_COUNT ]; do
        http_status=$(curl -s -o /dev/null -w "%{http_code}" "$APP_URL")

        if [ "$http_status" == "200" ]; then
            echo "up"
            return
        fi

        retries=$((retries + 1))
        sleep $RETRY_INTERVAL
    done

    echo "down"
}

# Function to send alert (stub function, to be implemented as needed)
send_alert() {
    local status="$1"
    # Implement your alerting logic here (email, SMS, etc.)
    log_message "${RED}ALERT: Application is $status!${RESET}"
}

# Main monitoring loop
while true; do
    app_status=$(check_app_status)

    if [ "$app_status" == "up" ]; then
        log_message "${GREEN}Application is up${RESET}"
        echo "up" > "$STATUS_FILE"
    else
        log_message "${RED}Application is down${RESET}"
        echo "down" > "$STATUS_FILE"
        send_alert "down"
    fi

    sleep $CHECK_INTERVAL
done
