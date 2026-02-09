#!/bin/bash
# GitHub Repository Setup and Push Script
# Usage: ./scripts/push-to-github.sh [repo-name]

set -e

REPO_NAME=${1:-"agent-zero-enterprise"}
GITHUB_USER=${GITHUB_USER:-"your-username"}

echo "🚀 Setting up GitHub Repository: $REPO_NAME"
echo "=============================================="
echo ""

# Check git
echo "📦 Checking Git..."
if ! command -v git &> /dev/null; then
    echo "❌ Git not installed"
    exit 1
fi
echo "   ✅ Git available"

# Check GitHub CLI
if ! command -v gh &> /dev/null; then
    echo "📥 Installing GitHub CLI..."
    # Linux installation
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg |         sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" |         sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update && sudo apt install gh -y
fi
echo "   ✅ GitHub CLI ready"

# Authenticate with GitHub
echo ""
echo "🔐 GitHub Authentication..."
if ! gh auth status &> /dev/null; then
    echo "   Please authenticate:"
    gh auth login
else
    echo "   ✅ Already authenticated"
    gh auth status
fi

# Get username if not set
if [ "$GITHUB_USER" = "your-username" ]; then
    GITHUB_USER=$(gh api user -q .login)
    echo "   GitHub user: $GITHUB_USER"
fi

# Create repository
echo ""
echo "📁 Creating repository..."
if gh repo view "$GITHUB_USER/$REPO_NAME" &> /dev/null; then
    echo "   Repository already exists, using existing..."
else
    gh repo create "$REPO_NAME" --public --description "Agent Zero Enterprise Deployment"         --source=. --remote=origin --push
    echo "   ✅ Repository created"
fi

# Configure git
echo ""
echo "⚙️  Configuring Git..."
git config user.name "Agent Zero Deployer" || true
git config user.email "deploy@agent-zero.local" || true

# Add files (excluding secrets)
echo ""
echo "📋 Adding files to git..."
git add -A

# Remove sensitive files from staging if they exist
git rm --cached secrets/ 2>/dev/null || true
git rm --cached .env 2>/dev/null || true
git rm --cached "*.key" 2>/dev/null || true

# Commit
echo "   Committing..."
git commit -m "Initial Agent Zero Enterprise deployment" || echo "   Nothing to commit"

# Push
echo ""
echo "🚀 Pushing to GitHub..."
git branch -M main 2>/dev/null || true
git push -u origin main || git push -u origin master

echo ""
echo "=============================================="
echo "✅ SUCCESS! Repository created and pushed"
echo "=============================================="
echo ""
echo "📍 Repository URL:"
echo "   https://github.com/$GITHUB_USER/$REPO_NAME"
echo ""
echo "🚀 Next steps:"
echo "   1. Visit: https://github.com/$GITHUB_USER/$REPO_NAME"
echo "   2. Set up Railway deployment from GitHub"
echo "   3. Add your OPENAI_API_KEY to Railway"
echo ""
