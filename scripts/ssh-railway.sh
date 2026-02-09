#!/bin/bash
# SSH Access Script for Agent Zero Enterprise
# Usage: ./scripts/ssh-railway.sh [command]

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SSH_KEY="$PROJECT_ROOT/secrets/ssh/agent_zero_deploy_key"

if [ ! -f "$SSH_KEY" ]; then
    echo "❌ SSH key not found at $SSH_KEY"
    echo "   Run: ./scripts/deploy-master.sh first"
    exit 1
fi

# Get Railway project info
echo "🔐 Connecting to Railway instance..."
PROJECT_ID=$(railway project 2>/dev/null | head -1 || echo "unknown")
echo "   Project: $PROJECT_ID"

# If no command provided, show info
if [ $# -eq 0 ]; then
    echo ""
    echo "💡 Usage:"
    echo "   ./scripts/ssh-railway.sh 'railway run bash'"
    echo "   ./scripts/ssh-railway.sh 'railway run logs'"
    echo ""
    echo "🔑 SSH Public Key:"
    cat "${SSH_KEY}.pub"
    exit 0
fi

# Execute command with SSH key
export GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"
"$@"
