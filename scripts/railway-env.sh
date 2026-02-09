#!/bin/bash
# Railway Environment Setup
# Source this file: source scripts/railway-env.sh

echo "🔧 Setting up Railway environment..."

# Client Credentials
export RAILWAY_CLIENT_ID="ecd8c21521690fa91ecaade2fcb751df"
export RAILWAY_CLIENT_SECRET="rlwy_oacs_ecd8c21521690fa91ecaade2fcb751df11b41dcc"

# Try to use client secret as token (works for some Railway setups)
export RAILWAY_TOKEN="rlwy_oacs_ecd8c21521690fa91ecaade2fcb751df11b41dcc"

# Alternative: Use just the token part
# export RAILWAY_TOKEN="rlwy_oacs_ecd8c21521690fa91ecaade2fcb751df11b41dcc"

echo "✅ Environment variables set"
echo "   RAILWAY_CLIENT_ID: $RAILWAY_CLIENT_ID"
echo "   RAILWAY_TOKEN: ${RAILWAY_TOKEN:0:20}..."
echo ""
echo "💡 To persist these, run:"
echo "   echo 'export RAILWAY_TOKEN=$RAILWAY_TOKEN' >> ~/.bashrc"
