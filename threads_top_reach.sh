#!/bin/bash
# Script to fetch Threads posts and sort by reach (views/engagement)
# Usage: ./threads_top_reach.sh <ACCOUNT_KEY> <SCAN_LIMIT> <RETURN_LIMIT>

ACCOUNT_KEY=$1
SCAN_LIMIT=${2:-50}
RETURN_LIMIT=${3:-20}

if [ -z "$ACCOUNT_KEY" ]; then
    echo "Usage: $0 <PRIMARY|SECONDARY> [SCAN_LIMIT] [RETURN_LIMIT]"
    exit 1
fi

source /app/data/Technomage/threads_config.sh

TOKEN_VAR="THREADS_ACCESS_TOKEN_$ACCOUNT_KEY"
TOKEN=${!TOKEN_VAR}

if [ -z "$TOKEN" ]; then
    echo "Error: Missing token for $ACCOUNT_KEY"
    exit 1
fi

echo "🔍 Analyzing reach for $ACCOUNT_KEY (Scanning last $SCAN_LIMIT posts)..." >&2

# 1. Fetch recent posts
POSTS_JSON=$(curl -s "https://graph.threads.net/v1.0/me/threads?fields=id,text,permalink,created_time&limit=$SCAN_LIMIT&access_token=$TOKEN")

# 2. Loop through and fetch insights
# We'll store results in a temp file: "total_engagement|likes|replies|text|link"
RESULTS_FILE=$(mktemp)

echo "$POSTS_JSON" | sed 's/},{"/\n/g' | while read -r line; do
    ID=$(echo "$line" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    TEXT=$(echo "$line" | grep -o '"text":"[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/\\n/ /g' | cut -c1-60)
    LINK=$(echo "$line" | grep -o '"permalink":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    if [ -n "$ID" ]; then
        # Fetch engagement metrics
        INSIGHTS=$(curl -s "https://graph.threads.net/v1.0/$ID/insights?metric=likes,replies,reposts,quotes&access_token=$TOKEN")
        
        # Breakdown JSON into sections per metric
        METRICS_LINES=$(echo "$INSIGHTS" | sed 's/{"name":/\n{"name":/g')
        
        LIKES=$(echo "$METRICS_LINES" | grep '"name":"likes"' | grep -o '"value":[0-9]*' | cut -d':' -f2 || echo 0)
        REPLIES=$(echo "$METRICS_LINES" | grep '"name":"replies"' | grep -o '"value":[0-9]*' | cut -d':' -f2 || echo 0)
        REPOSTS=$(echo "$METRICS_LINES" | grep '"name":"reposts"' | grep -o '"value":[0-9]*' | cut -d':' -f2 || echo 0)
        QUOTES=$(echo "$METRICS_LINES" | grep '"name":"quotes"' | grep -o '"value":[0-9]*' | cut -d':' -f2 || echo 0)
        
        # Default to 0 if empty
        LIKES=${LIKES:-0}
        REPLIES=${REPLIES:-0}
        REPOSTS=${REPOSTS:-0}
        QUOTES=${QUOTES:-0}
        
        TOTAL=$((LIKES + REPLIES + REPOSTS + QUOTES))
        
        echo "$TOTAL|$LIKES|$REPLIES|$TEXT|$LINK" >> "$RESULTS_FILE"
    fi
done

echo "🏆 TOP $RETURN_LIMIT POSTS BY ENGAGEMENT (Likes + Replies + Reposts):"
echo "---------------------------------------------------------------"

# 3. Sort by total descending and format
sort -t'|' -k1 -nr "$RESULTS_FILE" | head -n "$RETURN_LIMIT" | while IFS='|' read -r total likes replies text link; do
    echo "🔥 Engagement Score: $total (❤️ $likes | 💬 $replies)"
    echo "📝 $text..."
    echo "🔗 $link"
    echo ""
done

rm "$RESULTS_FILE"
