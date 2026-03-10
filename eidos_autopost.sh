#!/bin/bash
# Eidos Threads Auto-Post Script

# Load config
source /app/data/Technomage/threads_config.sh

# Get current time
NOW=$(date +%s)
LAST_POST_FILE="/app/data/Technomage/last_post_time.txt"

if [ -f "$LAST_POST_FILE" ]; then
    LAST_POST_TIME=$(cat "$LAST_POST_FILE")
else
    LAST_POST_TIME=0
fi

# 3 hours = 10800 seconds
INTERVAL=10800
DIFF=$((NOW - LAST_POST_TIME))

if [ $DIFF -ge $INTERVAL ]; then
    echo "Running auto-post..."
    # Logic to select next post and publish via curl would go here
    # For now, we just log that it's time
    echo $NOW > "$LAST_POST_FILE"
else
    echo "Too early to post. Next post in $((INTERVAL - DIFF)) seconds."
fi
