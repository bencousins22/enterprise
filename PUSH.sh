#!/bin/bash
# One-click setup and push for bencousins22/enterprise

set -e

cd "$(dirname "$0")"

echo "🚀 Agent Zero Enterprise - GitHub Push"
echo "======================================"
echo ""

# Initialize git
echo "📦 Initializing git..."
git init
git config user.email "biometglobal@gmail.com"
git config user.name "bencousins22"

echo ""
echo "🔗 Adding remote..."
git remote add origin "https://${GITHUB_TOKEN}@github.com/bencousins22/enterprise.git" 2>/dev/null || true

echo ""
echo "📋 Adding files..."
git add -A

echo ""
echo "💾 Committing..."
git commit -m "Agent Zero Enterprise deployment" || true

echo ""
echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main --force

echo ""
echo "======================================"
echo "✅ SUCCESS!"
echo "======================================"
echo ""
echo "🌐 https://github.com/bencousins22/enterprise"
echo ""
echo "Next - Deploy to Railway:"
echo "   export RAILWAY_TOKEN=${RAILWAY_TOKEN}"
echo "   ./scripts/deploy-master.sh"
echo ""
