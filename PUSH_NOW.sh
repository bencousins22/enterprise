#!/bin/bash
# GitHub Push Script - Agent Zero Enterprise
# Generated automatically

set -e

GITHUB_TOKEN="${GITHUB_TOKEN}"
REPO_NAME="agent-zero-enterprise"

echo "🚀 PUSHING TO GITHUB"
echo "===================="
echo ""

# Get username
echo "🔐 Authenticating..."
USER_JSON=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
USERNAME=$(echo $USER_JSON | grep -o '"login": "[^"]*"' | cut -d'"' -f4)

echo "   Username: $USERNAME"
echo ""

# Check if repo exists
echo "📁 Checking repository..."
if curl -s -H "Authorization: token $GITHUB_TOKEN"    "https://api.github.com/repos/$USERNAME/$REPO_NAME" | grep -q "Not Found"; then

    echo "   Creating repository..."
    curl -s -H "Authorization: token $GITHUB_TOKEN"          -H "Accept: application/vnd.github.v3+json"          -d '{"name": "'$REPO_NAME'", "private": false, "description": "Agent Zero Enterprise Deployment", "auto_init": false}'          https://api.github.com/user/repos
    echo "   ✅ Repository created"
else
    echo "   ✅ Repository exists"
fi

echo ""
echo "⚙️  Configuring git..."

# Set git config
git config user.email "deploy@agentzero.local" || true
git config user.name "AgentZero Deployer" || true

# Remove any existing origin
git remote remove origin 2>/dev/null || true

# Add origin with token embedded
git remote add origin "https://$GITHUB_TOKEN@github.com/$USERNAME/$REPO_NAME.git"

echo "   ✅ Remote configured"
echo ""

# Stage all files
echo "📦 Staging files..."
git add -A

# Commit
echo "💾 Committing..."
git commit -m "Initial Agent Zero Enterprise deployment

- Railway optimized configuration
- Docker containerization
- Nginx load balancer
- PostgreSQL + Redis
- Enterprise security features
- Automated deployment scripts" || echo "Already committed"

echo "   ✅ Committed"
echo ""

# Push
echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main --force

echo ""
echo "===================="
echo "✅ SUCCESS!"
echo "===================="
echo ""
echo "📍 Repository URL:"
echo "   https://github.com/$USERNAME/$REPO_NAME"
echo ""
echo "🚀 NEXT STEP - Deploy to Railway:"
echo "   export RAILWAY_TOKEN=${RAILWAY_TOKEN}"
echo "   cd agent-zero-src && railway up"
echo ""

# Open browser if possible
if command -v xdg-open &> /dev/null; then
    xdg-open "https://github.com/$USERNAME/$REPO_NAME" &
elif command -v open &> /dev/null; then
    open "https://github.com/$USERNAME/$REPO_NAME" &
fi
