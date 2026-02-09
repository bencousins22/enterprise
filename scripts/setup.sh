#!/bin/bash
# Agent Zero Enterprise Railway Deployer
# Usage: ./setup.sh [project-name] [branch]

set -e

REPO_URL="https://github.com/agent0ai/agent-zero"
PROJECT_NAME=${1:-"agent-zero-enterprise"}
BRANCH=${2:-"development"}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🎯 Agent Zero Enterprise Railway Deployer"
echo "=========================================="
echo "Project: $PROJECT_NAME"
echo "Branch: $BRANCH"
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check prerequisites
check_prereq() {
    if ! command -v $1 &> /dev/null; then
        echo -e "${RED}❌ $1 is required but not installed.${NC}"
        return 1
    fi
    echo -e "${GREEN}✅ $1 found${NC}"
}

echo "🔍 Checking prerequisites..."
check_prereq git || exit 1
check_prereq railway || { echo "Install Railway CLI: npm i -g @railway/cli"; exit 1; }
check_prereq docker || echo -e "${YELLOW}⚠️  Docker not found (optional for local testing)${NC}"

echo ""

# Clone repository
echo "📥 Cloning Agent Zero repository..."
if [ -d "$PROJECT_NAME" ]; then
    echo -e "${YELLOW}⚠️  Directory $PROJECT_NAME already exists${NC}"
    read -p "Remove and re-clone? (y/N): " confirm
    if [[ $confirm =~ ^[Yy]$ ]]; then
        rm -rf "$PROJECT_NAME"
        git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$PROJECT_NAME"
    else
        echo "Using existing directory..."
    fi
else
    git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$PROJECT_NAME"
fi

cd "$PROJECT_NAME"
echo -e "${GREEN}✅ Repository ready at $(pwd)${NC}"

# Copy enterprise files
echo ""
echo "🏗️  Setting up enterprise configuration..."
cp "$SCRIPT_DIR/../Dockerfile.railway" .
cp "$SCRIPT_DIR/../railway.toml" .
cp "$SCRIPT_DIR/../start.sh" .
cp "$SCRIPT_DIR/../nginx.conf" .
cp "$SCRIPT_DIR/../docker-compose.yml" .
cp "$SCRIPT_DIR/../.env.example" .

# Initialize Railway project
echo ""
echo "🚂 Initializing Railway project..."
railway login

if ! railway status &> /dev/null; then
    echo "Creating new Railway project..."
    railway init --name "$PROJECT_NAME"
else
    echo -e "${YELLOW}⚠️  Already in a Railway project${NC}"
    read -p "Continue with current project? (y/N): " confirm
    [[ $confirm =~ ^[Yy]$ ]] || exit 1
fi

# Add required services
echo ""
echo "🗄️  Provisioning services..."

echo "   Adding PostgreSQL..."
railway add --database postgres || echo -e "${YELLOW}   PostgreSQL may already exist${NC}"

echo "   Adding Redis..."
railway add --database redis || echo -e "${YELLOW}   Redis may already exist${NC}"

echo "   Adding persistent volume..."
railway volume add data --mount-path /app/data || echo -e "${YELLOW}   Volume may already exist${NC}"

# Environment configuration
echo ""
echo "⚙️  Configuring environment variables..."

# Generate secure random secret
AUTH_SECRET=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)

railway variables set     AGENT_NAME="Enterprise-Agent"     LOG_LEVEL="INFO"     AUTH_REQUIRED="true"     AUTH_SECRET="$AUTH_SECRET"     ENTERPRISE_MODE="true"     MEMORY_BACKEND="redis"     KNOWLEDGE_BASE_ENABLED="true"     RAILWAY_ENVIRONMENT="production"

echo ""
echo -e "${GREEN}✅ Base configuration complete${NC}"

# Prompt for API keys
echo ""
echo "🔑 Configure AI Provider API Keys:"
echo "(These will be stored securely in Railway's environment)"
read -p "OpenAI API Key (sk-...): " openai_key
if [ -n "$openai_key" ]; then
    railway variables set OPENAI_API_KEY="$openai_key"
    echo -e "${GREEN}✅ OpenAI configured${NC}"
fi

read -p "Anthropic API Key (sk-ant-...) [Optional]: " anthropic_key
if [ -n "$anthropic_key" ]; then
    railway variables set ANTHROPIC_API_KEY="$anthropic_key"
    echo -e "${GREEN}✅ Anthropic configured${NC}"
fi

# Deployment
echo ""
echo "🚀 Ready to deploy!"
read -p "Deploy to Railway now? (Y/n): " deploy_confirm
deploy_confirm=${deploy_confirm:-Y}

if [[ $deploy_confirm =~ ^[Yy]$ ]]; then
    echo "Building and deploying..."
    railway up --detach

    echo ""
    echo -e "${GREEN}✅ Deployment initiated!${NC}"
    echo ""
    echo "📊 Monitor deployment at:"
    echo "   $(railway open --print-only)"
    echo ""
    echo "🌐 Once deployed, your instance will be available at:"
    railway domain
else
    echo ""
    echo "Deployment skipped. Deploy manually with:"
    echo "   railway up"
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Setup complete!"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Next steps:"
echo "  1. Configure custom domain: railway domain"
echo "  2. View logs: railway logs"
echo "  3. Add team members: railway collaborator add <email>"
echo "  4. Enable backups: railway backup"
echo ""
echo "Documentation: ./docs/ENTERPRISE_DEPLOY.md"
echo ""
