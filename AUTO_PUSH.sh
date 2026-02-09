#!/bin/bash
# Auto-GitHub Setup Script
# This script will create a GitHub repo and push the code

set -e

REPO_NAME="agent-zero-enterprise"

echo "🚀 Auto GitHub Setup"
echo "===================="
echo ""

# Check for GitHub token
if [ -z "$GITHUB_TOKEN" ]; then
    echo "🔑 GitHub Token required"
    echo "   Get one at: https://github.com/settings/tokens"
    echo "   Required scopes: repo, workflow"
    read -p "Enter GitHub Token: " GITHUB_TOKEN
    export GITHUB_TOKEN
fi

# Get GitHub username
USERNAME=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user | jq -r .login)
echo "   GitHub User: $USERNAME"

# Check if repo exists
echo ""
echo "📁 Checking repository..."
if curl -s -H "Authorization: token $GITHUB_TOKEN"    https://api.github.com/repos/$USERNAME/$REPO_NAME | grep -q "Not Found"; then

    echo "   Creating repository..."
    curl -s -H "Authorization: token $GITHUB_TOKEN"          -d "{\"name\": \"$REPO_NAME\", \"private\": false, \"description\": \"Agent Zero Enterprise Deployment\"}"          https://api.github.com/user/repos
    echo "   ✅ Repository created"
else
    echo "   ✅ Repository exists"
fi

# Setup git remote
echo ""
echo "⚙️  Configuring git..."
git remote remove origin 2>/dev/null || true
git remote add origin https://$GITHUB_TOKEN@github.com/$USERNAME/$REPO_NAME.git

# Push
echo ""
echo "🚀 Pushing to GitHub..."
git branch -M main
git push -u origin main --force

echo ""
echo "===================================="
echo "✅ SUCCESS!"
echo "===================================="
echo ""
echo "📍 Repository: https://github.com/$USERNAME/$REPO_NAME"
echo ""
echo "🚀 Next: Deploy to Railway"
echo "   export RAILWAY_TOKEN=your_token"
echo "   railway up"
