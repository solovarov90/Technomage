#!/bin/bash
# Multi-Account Threads Posting Utility
# Usage: ./publish_threads_multi.sh <account_key> "Message 1" "Message 2" ...
# account_key: PRIMARY or SECONDARY

ACCOUNT_KEY=$1
shift

if [ -z "$ACCOUNT_KEY" ] || [ $# -eq 0 ]; then
    echo "Usage: $0 <PRIMARY|SECONDARY> \"Message 1\" \"Message 2\" ..."
    exit 1
fi

# Load config
source /app/data/Technomage/threads_config.sh

# Dynamic variable selection
TOKEN_VAR="THREADS_ACCESS_TOKEN_$ACCOUNT_KEY"
USER_ID_VAR="THREADS_USER_ID_$ACCOUNT_KEY"

TOKEN=${!TOKEN_VAR}
USER_ID=${!USER_ID_VAR}

if [ -z "$TOKEN" ] || [ -z "$USER_ID" ]; then
    echo "Error: Invalid account key or missing config for $ACCOUNT_KEY"
    exit 1
fi

publish_step() {
    local text="$1"
    local reply_to="$2"
    local container_id
    local post_id
    
    # Create media container
    if [ -z "$reply_to" ]; then
        container_id=$(curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads" \
            --data-urlencode "text=$text" \
            --data-urlencode "media_type=TEXT" \
            --data-urlencode "access_token=$TOKEN" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
    else
        container_id=$(curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads" \
            --data-urlencode "text=$text" \
            --data-urlencode "media_type=TEXT" \
            --data-urlencode "reply_to_id=$reply_to" \
            --data-urlencode "access_token=$TOKEN" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
    fi
    
    if [ -z "$container_id" ]; then
        return 1
    fi
    
    # Wait for processing
    sleep 3
    
    # Publish container
    post_id=$(curl -s -X POST "https://graph.threads.net/v1.0/$USER_ID/threads_publish" \
        --data-urlencode "creation_id=$container_id" \
        --data-urlencode "access_token=$TOKEN" | grep -o '"id":"[^"]*' | cut -d'"' -f4)
        
    echo "$post_id"
}

LAST_ID=""
for MSG in "$@"; do
    CLEAN_MSG=$(echo -e "$MSG")
    NEXT_ID=$(publish_step "$CLEAN_MSG" "$LAST_ID")
    if [ -z "$NEXT_ID" ]; then
        echo "FAILED_TO_POST"
        exit 1
    fi
    echo "POSTED:$NEXT_ID"
    LAST_ID="$NEXT_ID"
    sleep 2
done
