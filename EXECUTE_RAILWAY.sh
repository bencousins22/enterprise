#!/bin/bash
cd /mnt/kimi/output/agent-zero-enterprise
export RAILWAY_TOKEN="${RAILWAY_TOKEN}"
export PATH="$PATH:$HOME/.railway/bin"
if ! command -v railway &> /dev/null; then
    curl -fsSL https://railway.app/install.sh | bash 2>&1 | tail -5
fi
railway login 2>&1 | head -3
railway init --name "agent-zero-enterprise" 2>&1 | head -5
railway up --detach 2>&1 | head -10
echo "RAILWAY DEPLOY COMPLETE"
