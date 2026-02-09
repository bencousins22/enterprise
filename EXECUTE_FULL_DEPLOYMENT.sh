#!/bin/bash
# Agent Zero Enterprise - Complete GitHub Push & Deploy
# Generated for automatic execution

set -e

cd "$(dirname "$0")"

echo "=========================================="
echo "🚀 AGENT ZERO ENTERPRISE DEPLOYMENT"
echo "=========================================="
echo ""

# GitHub Configuration
GITHUB_TOKEN="${GITHUB_TOKEN}"
REPO_NAME="agent-zero-enterprise"
RAILWAY_TOKEN="${RAILWAY_TOKEN}"

echo "🔐 Connecting to GitHub..."
USERNAME=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | grep -o '"login": "[^"]*"' | cut -d'"' -f4)
echo "   ✅ Connected as: $USERNAME"
echo ""

echo "📁 Setting up repository..."
if ! curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$USERNAME/$REPO_NAME" | grep -q "id"; then
    echo "   Creating repository..."
    curl -s -H "Authorization: token $GITHUB_TOKEN" -H "Accept: application/vnd.github.v3+json"          -d "{\"name\": \"$REPO_NAME\", \"private\": false, \"auto_init\": false}"          https://api.github.com/user/repos > /dev/null
    echo "   ✅ Created"
else
    echo "   ✅ Repository exists"
fi
echo ""

echo "⚙️  Configuring git..."
git init 2>/dev/null || true
git config user.email "deploy@agentzero.local" 2>/dev/null || true
git config user.name "AgentZero" 2>/dev/null || true
git remote remove origin 2>/dev/null || true
git remote add origin "https://$GITHUB_TOKEN@github.com/$USERNAME/$REPO_NAME.git" 2>/dev/null || true
echo "   ✅ Configured"
echo ""

echo "📦 Committing files..."
git add -A 2>/dev/null || true
git commit -m "Agent Zero Enterprise deployment $(date +%s)" 2>/dev/null || true
echo "   ✅ Committed"
echo ""

echo "🚀 Pushing to GitHub..."
git branch -M main 2>/dev/null || true
if git push -u origin main --force 2>/dev/null; then
    echo "   ✅ Pushed successfully!"
else
    echo "   ⚠️  Git push failed, trying API upload..."
    # Fallback to API upload for key files
    for file in README.md Dockerfile.railway railway.toml start.sh nginx.conf docker-compose.yml; do
        if [ -f "$file" ]; then
            CONTENT=$(base64 -w 0 "$file" 2>/dev/null || openssl base64 -A -in "$file")
            curl -s -X PUT -H "Authorization: token $GITHUB_TOKEN"                  -H "Accept: application/vnd.github.v3+json"                  -d "{\"message\": \"Add $file\", \"content\": \"$CONTENT\"}"                  "https://api.github.com/repos/$USERNAME/$REPO_NAME/contents/$file" > /dev/null
            echo "   📄 $file"
        fi
    done
    echo "   ✅ Core files uploaded via API"
fi
echo ""

echo "=========================================="
echo "✅ SUCCESS!"
echo "=========================================="
echo ""
echo "📍 GitHub Repository:"
echo "   https://github.com/$USERNAME/$REPO_NAME"
echo ""
echo "🚀 NEXT - Deploy to Railway:"
echo "   export RAILWAY_TOKEN=$RAILWAY_TOKEN"
echo "   railway login"
echo "   ./scripts/deploy-master.sh"
echo ""
echo "Or one-liner:"
echo "   RAILWAY_TOKEN=$RAILWAY_TOKEN ./scripts/deploy-master.sh"
echo ""

# Try to open browser
if command -v xdg-open &> /dev/null; then
    xdg-open "https://github.com/$USERNAME/$REPO_NAME" 2>/dev/null || true
elif command -v open &> /dev/null; then
    open "https://github.com/$USERNAME/$REPO_NAME" 2>/dev/null || true
fi
