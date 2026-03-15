#!/bin/bash
# Eidos Threads Threading Utility
# Usage: ./publish_threads_entry.sh "Message 1" "Message 2" ...

TOKEN=$(grep 'THREADS_ACCESS_TOKEN=' /app/data/Technomage/threads_config.sh | cut -d'"' -f2)
USER_ID="26202122892761460"

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"Message 1\" \"Message 2\" ..."
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
    # Replace literal \n with real newlines if they come from strings
    # (Though better to pass clean strings)
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
