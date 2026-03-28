#!/bin/bash
# Parser for Threads posts
# Usage: ./parse_threads_top.sh <ACCOUNT_KEY> <LIMIT>

ACCOUNT_KEY=$1
LIMIT=${2:-20}

if [ -z "$ACCOUNT_KEY" ]; then
    echo "Usage: $0 <PRIMARY|SECONDARY> [LIMIT]"
    exit 1
fi

source /app/data/Technomage/threads_config.sh

TOKEN_VAR="THREADS_ACCESS_TOKEN_$ACCOUNT_KEY"
TOKEN=${!TOKEN_VAR}

if [ -z "$TOKEN" ]; then
    echo "Error: Missing token for $ACCOUNT_KEY"
    exit 1
fi

echo "🔍 Scanning Threads for $ACCOUNT_KEY..." >&2

# Fetch posts
POSTS_JSON=$(curl -s "https://graph.threads.net/v1.0/me/threads?fields=id,text,permalink,created_time&limit=$LIMIT&access_token=$TOKEN")

if echo "$POSTS_JSON" | grep -q "error"; then
    echo "Error fetching posts: $POSTS_JSON"
    exit 1
fi

# Fetch posts using a more robust grep pattern for JSON data
POSTS_JSON=$(curl -s "https://graph.threads.net/v1.0/me/threads?fields=id,text,permalink,created_time&limit=$LIMIT&access_token=$TOKEN")

if echo "$POSTS_JSON" | grep -q "error"; then
    echo "Error fetching posts: $POSTS_JSON"
    exit 1
fi

# Manual JSON parsing for environments without jq
echo "$POSTS_JSON" | sed 's/},{"/\n/g' | while read -r line; do
    TIME=$(echo "$line" | grep -o '"created_time":"[^"]*"' | head -1 | cut -d'"' -f4)
    TEXT=$(echo "$line" | grep -o '"text":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/\\n/ /g' | cut -c1-60)
    LINK=$(echo "$line" | grep -o '"permalink":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -n "$LINK" ]; then
        echo "[$TIME] $TEXT..."
        echo "🔗 $LINK"
        echo ""
    fi
done
