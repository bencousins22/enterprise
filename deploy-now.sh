#!/bin/bash
# Fresh Deployment with New Token
set -e

PROJECT_NAME="agent-zero-enterprise-$(date +%s)"
BRANCH="development"
RAILWAY_TOKEN="${RAILWAY_TOKEN}"

echo "🚀 AGENT ZERO ENTERPRISE DEPLOYMENT"
echo "===================================="
echo "Token: ${RAILWAY_TOKEN:0:8}...${RAILWAY_TOKEN: -4}"
echo ""

# Export token
export RAILWAY_TOKEN

# Step 1: Check/Install Railway CLI
echo "📦 Step 1: Checking Railway CLI..."
if ! command -v railway &> /dev/null; then
    echo "   Installing Railway CLI..."
    curl -fsSL https://railway.app/install.sh | bash
    export PATH="$HOME/.railway/bin:$PATH"
fi
echo "   ✅ Railway CLI ready"

# Step 2: Authenticate
echo ""
echo "🔐 Step 2: Authenticating..."
railway --version
if railway whoami; then
    echo "   ✅ Authentication successful"
else
    echo "   ⚠️  Trying alternative auth..."
    echo "$RAILWAY_TOKEN" | railway login --token
fi

# Step 3: Clone Repository
echo ""
echo "📥 Step 3: Cloning Agent Zero..."
REPO_DIR="agent-zero-src"
if [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
fi
git clone --branch "$BRANCH" --depth 1 https://github.com/agent0ai/agent-zero.git "$REPO_DIR"
cd "$REPO_DIR"
echo "   ✅ Cloned to $REPO_DIR"

# Step 4: Copy enterprise files
echo ""
echo "🏗️  Step 4: Configuring enterprise..."
cp ../Dockerfile.railway .
cp ../railway.toml .
cp ../start.sh .
cp ../nginx.conf .
echo "   ✅ Enterprise files copied"

# Step 5: Create Railway project
echo ""
echo "🚂 Step 5: Creating Railway project..."
railway init --name "$PROJECT_NAME" --description "Agent Zero Enterprise Instance"
echo "   ✅ Project created: $PROJECT_NAME"

# Step 6: Add services
echo ""
echo "🗄️  Step 6: Provisioning services..."
railway add --database postgres || echo "   PostgreSQL may already exist"
railway add --database redis || echo "   Redis may already exist"
railway volume add data --mount-path /app/data || echo "   Volume may already exist"
echo "   ✅ Services provisioned"

# Step 7: Set environment
echo ""
echo "⚙️  Step 7: Setting environment variables..."
AUTH_SECRET=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)

railway variables set \
    AGENT_NAME="Enterprise-Agent-Zero" \
    LOG_LEVEL="INFO" \
    AUTH_REQUIRED="true" \
    AUTH_SECRET="$AUTH_SECRET" \
    ENTERPRISE_MODE="true" \
    MEMORY_BACKEND="redis" \
    KNOWLEDGE_BASE_ENABLED="true" \
    RAILWAY_ENVIRONMENT="production" \
    MAX_CONCURRENT_AGENTS="10" \
    WORKERS="4"

echo "   ✅ Environment configured"

# Step 8: Deploy
echo ""
echo "🚀 Step 8: Deploying..."
railway up --detach

# Step 9: Get info
echo ""
echo "📊 Deployment Info:"
sleep 5
DOMAIN=$(railway domain 2>/dev/null || echo "Pending...")
PROJECT_URL=$(railway open --print-only 2>/dev/null || echo "Run: railway open")

echo "   Domain: $DOMAIN"
echo "   Dashboard: $PROJECT_URL"

echo ""
echo "===================================="
echo "✅ DEPLOYMENT COMPLETE!"
echo "===================================="
echo ""
echo "Next steps:"
echo "  1. Add OpenAI API key:"
echo "     railway variables set OPENAI_API_KEY=sk-..."
echo ""
echo "  2. Check status:"
echo "     railway status"
echo ""
echo "  3. View logs:"
echo "     railway logs"
echo ""
echo "  4. Access app:"
echo "     https://$DOMAIN"
