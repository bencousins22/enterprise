#!/bin/bash
# Railway Client Credentials Authentication
# Usage: ./scripts/auth-programmatic.sh

set -e

CLIENT_ID="ecd8c21521690fa91ecaade2fcb751df"
CLIENT_SECRET="rlwy_oacs_ecd8c21521690fa91ecaade2fcb751df11b41dcc"

echo "🔐 Railway Client Credentials Auth"
echo "=================================="
echo ""

# Method 1: Using Railway CLI with token exchange
# Railway doesn't directly support client credentials in CLI, 
# so we exchange for an access token

echo "🔄 Exchanging client credentials for access token..."

# Exchange credentials for token
TOKEN_RESPONSE=$(curl -s -X POST https://railway.app/api/v1/oauth/token \
  -H "Content-Type: application/json" \
  -d "{\"client_id\": \"$CLIENT_ID\", \"client_secret\": \"$CLIENT_SECRET\", \"grant_type\": \"client_credentials\"}")

# Extract token (if this endpoint exists)
ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.access_token // empty')

if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
    echo "✅ Authentication successful"
    export RAILWAY_TOKEN="$ACCESS_TOKEN"
    echo "export RAILWAY_TOKEN=$ACCESS_TOKEN" >> ~/.bashrc
    echo "export RAILWAY_TOKEN=$ACCESS_TOKEN" >> ~/.zshrc 2>/dev/null || true
    echo "   Token saved to shell profiles"
else
    echo "⚠️  Client credentials flow not available via API"
    echo "   Falling back to token-based auth..."
    echo ""
    echo "📝 To authenticate programmatically:"
    echo "   1. Go to: https://railway.app/account/tokens"
    echo "   2. Create a new token"
    echo "   3. Run: export RAILWAY_TOKEN=your_token"
    echo ""
    echo "   Or use the client secret as token:"
    export RAILWAY_TOKEN="$CLIENT_SECRET"
    echo "   export RAILWAY_TOKEN=$CLIENT_SECRET"
fi

echo ""
echo "🔍 Verifying..."
railway whoami || echo "⚠️  Verification failed - token may need different format"
