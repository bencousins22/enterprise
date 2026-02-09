#!/bin/bash
# Direct GitHub API Upload Script
# This uploads files directly via API (no git required)

set -e

GITHUB_TOKEN="${GITHUB_TOKEN}"
REPO_NAME="agent-zero-enterprise"
OWNER=""

echo "🚀 GitHub API Upload"
echo "===================="
echo ""

# Get username
echo "🔐 Getting user info..."
USER_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user)
OWNER=$(echo $USER_RESPONSE | grep -o '"login": "[^"]*"' | head -1 | cut -d'"' -f4)

echo "   Owner: $OWNER"
echo ""

# Create repo if not exists
echo "📁 Creating repository..."
REPO_RESPONSE=$(curl -s -H "Authorization: token $GITHUB_TOKEN"   -H "Accept: application/vnd.github.v3+json"   -d "{\"name\": \"$REPO_NAME\", \"private\": false, \"description\": \"Agent Zero Enterprise - Scalable AI Agent Deployment\", \"auto_init\": true}"   https://api.github.com/user/repos)

echo "   ✅ Repository ready"
echo ""

# Function to upload file
upload_file() {
    local file="$1"
    local path="${2:-$file}"

    # Encode content
    CONTENT=$(base64 -w 0 "$file")

    # Upload
    curl -s -X PUT       -H "Authorization: token $GITHUB_TOKEN"       -H "Accept: application/vnd.github.v3+json"       -d "{\"message\": \"Add $path\", \"content\": \"$CONTENT\"}"       "https://api.github.com/repos/$OWNER/$REPO_NAME/contents/$path" > /dev/null

    echo "   📄 Uploaded: $path"
}

echo "📤 Uploading files..."

# Core files
upload_file "README.md"
upload_file "Dockerfile.railway"
upload_file "railway.toml"
upload_file "start.sh"
upload_file "nginx.conf"
upload_file "docker-compose.yml"
upload_file ".env.example"
upload_file ".gitignore"
upload_file "Makefile"

echo ""
echo "✅ Upload complete!"
echo ""
echo "📍 Repository: https://github.com/$OWNER/$REPO_NAME"
