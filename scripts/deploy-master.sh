#!/bin/bash
# Master Deployment Script - Agent Zero Enterprise
# Usage: ./scripts/deploy-master.sh [project-name] [branch]

set -e

PROJECT_NAME=${1:-"agent-zero-enterprise"}
BRANCH=${2:-"development"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🚀 AGENT ZERO ENTERPRISE - MASTER DEPLOYMENT"
echo "=============================================="
echo "Project: $PROJECT_NAME"
echo "Branch: $BRANCH"
echo ""

# Source Railway credentials
export RAILWAY_CLIENT_ID="ecd8c21521690fa91ecaade2fcb751df"
export RAILWAY_CLIENT_SECRET="rlwy_oacs_ecd8c21521690fa91ecaade2fcb751df11b41dcc"
export RAILWAY_TOKEN="rlwy_oacs_ecd8c21521690fa91ecaade2fcb751df11b41dcc"

# SSH Key setup
SSH_KEY="$PROJECT_ROOT/secrets/ssh/agent_zero_deploy_key"
export GIT_SSH_COMMAND="ssh -i $SSH_KEY -o IdentitiesOnly=yes -o StrictHostKeyChecking=no"

echo "🔐 Credentials configured:"
echo "   Client ID: ${RAILWAY_CLIENT_ID:0:8}..."
echo "   Token: ${RAILWAY_TOKEN:0:20}..."
echo "   SSH Key: $SSH_KEY"
echo ""

# Check prerequisites
echo "🔍 Checking prerequisites..."
if ! command -v railway &> /dev/null; then
    echo "📦 Installing Railway CLI..."
    npm install -g @railway/cli || curl -fsSL https://railway.app/install.sh | bash
fi

if ! command -v git &> /dev/null; then
    echo "❌ Git is required"
    exit 1
fi

echo "✅ Prerequisites met"
echo ""

# Verify Railway authentication
echo "🔐 Authenticating with Railway..."
if ! railway whoami &> /dev/null; then
    echo "   Attempting token authentication..."
    # Try to use token
    echo "$RAILWAY_TOKEN" | railway login --token
fi

if railway whoami; then
    echo "✅ Railway authentication successful"
else
    echo "⚠️  Railway auth failed, continuing anyway..."
fi
echo ""

# Clone or update repository
echo "📥 Setting up Agent Zero repository..."
REPO_DIR="$PROJECT_ROOT/agent-zero"

if [ -d "$REPO_DIR/.git" ]; then
    echo "   Updating existing repository..."
    cd "$REPO_DIR"
    git fetch origin
    git checkout "$BRANCH"
    git pull origin "$BRANCH"
else
    echo "   Cloning repository..."
    git clone --branch "$BRANCH" --single-branch         https://github.com/agent0ai/agent-zero.git "$REPO_DIR"
    cd "$REPO_DIR"
fi

echo "✅ Repository ready at $REPO_DIR"
echo ""

# Copy enterprise files
echo "🏗️  Configuring enterprise setup..."
cp "$PROJECT_ROOT/Dockerfile.railway" .
cp "$PROJECT_ROOT/railway.toml" .
cp "$PROJECT_ROOT/start.sh" .
cp "$PROJECT_ROOT/nginx.conf" .
cp "$PROJECT_ROOT/.env.example" .env

echo "✅ Enterprise files copied"
echo ""

# Initialize Railway project if needed
echo "🚂 Configuring Railway project..."
if [ ! -f ".railway/config.json" ]; then
    echo "   Creating new Railway project..."
    railway init --name "$PROJECT_NAME" || true
else
    echo "   Using existing Railway project"
fi

# Add services
echo "🗄️  Provisioning services..."
railway add --database postgres 2>/dev/null || echo "   PostgreSQL: already exists or will be created"
railway add --database redis 2>/dev/null || echo "   Redis: already exists or will be created"
railway volume add data --mount-path /app/data 2>/dev/null || echo "   Volume: already exists"

# Set environment variables
echo "⚙️  Configuring environment..."
railway variables set \
    AGENT_NAME="Enterprise-Agent" \
    LOG_LEVEL="INFO" \
    AUTH_REQUIRED="true" \
    AUTH_SECRET="$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)" \
    ENTERPRISE_MODE="true" \
    MEMORY_BACKEND="redis" \
    KNOWLEDGE_BASE_ENABLED="true" \
    RAILWAY_ENVIRONMENT="production" \
    ENABLE_SSH="true" \
    SSH_PRIVATE_KEY="$(cat $SSH_KEY)" \
    SSH_PUBLIC_KEY="$(cat ${SSH_KEY}.pub)"

echo "✅ Environment configured"
echo ""

# Deployment
echo "🚀 Deploying to Railway..."
railway up --detach

echo ""
echo "=============================================="
echo "✅ DEPLOYMENT INITIATED!"
echo "=============================================="
echo ""

# Get domain
DOMAIN=$(railway domain 2>/dev/null || echo "Pending...")
echo "🌐 Domain: $DOMAIN"
echo "📊 Dashboard: $(railway open --print-only 2>/dev/null || echo 'Run: railway open')"
echo ""
echo "🔑 SSH Key for server access:"
cat "${SSH_KEY}.pub"
echo ""
echo "Next steps:"
echo "  1. Add your OpenAI API key: railway variables set OPENAI_API_KEY=sk-..."
echo "  2. Monitor deployment: railway logs"
echo "  3. Check health: curl https://$DOMAIN/health"
echo ""
