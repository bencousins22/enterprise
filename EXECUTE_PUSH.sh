#!/bin/bash
cd /mnt/kimi/output/agent-zero-enterprise
git config user.email "biometglobal@gmail.com"
git config user.name "bencousins22"
git remote remove origin 2>/dev/null
git remote add origin "https://${GITHUB_TOKEN}@github.com/bencousins22/agent-zero-enterprise.git"
git add -A 2>/dev/null
git commit -m "Agent Zero Enterprise deployment" 2>/dev/null
git branch -M main 2>/dev/null
git push -u origin main --force 2>&1
echo "GITHUB PUSH COMPLETE"
