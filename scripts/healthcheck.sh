#!/bin/bash
# Health check script for monitoring

ENDPOINT="${1:-http://localhost:80/health}"
TIMEOUT=10

response=$(curl -s -o /dev/null -w "%{http_code}" --max-time $TIMEOUT "$ENDPOINT")

if [ "$response" == "200" ]; then
    echo "✅ Healthy (HTTP 200)"
    exit 0
else
    echo "❌ Unhealthy (HTTP $response)"
    exit 1
fi
