#!/bin/bash
# Fetch comments from Threads

TOKEN=$(grep 'THREADS_ACCESS_TOKEN=' /app/data/Technomage/threads_config.sh | cut -d'"' -f2)
USER_ID="26202122892761460"

# Fetch list of recent threads
echo "Fetching recent threads..." >&2
THREADS_JSON=$(curl -s "https://graph.threads.net/v1.0/me/threads?fields=id,text,created_time&access_token=$TOKEN")

# For each thread, fetch comments
echo "$THREADS_JSON" | grep -o '"id":"[^"]*' | cut -d'"' -f4 | while read -r thread_id; do
    echo "--- Thread $thread_id ---"
    TEXT=$(echo "$THREADS_JSON" | grep -A 2 "$thread_id" | grep '"text"' | cut -d'"' -f4)
    echo "Post: $TEXT"
    
    COMMENTS=$(curl -s "https://graph.threads.net/v1.0/$thread_id/replies?fields=id,text,username,timestamp&access_token=$TOKEN")
    echo "Comments: $COMMENTS"
done
