# 🔐 Railway Authentication Guide

## Quick Setup (Choose One Method)

### Method 1: Interactive Login (Recommended for Development)

```bash
# Install Railway CLI if not already installed
npm install -g @railway/cli

# Login (opens browser)
railway login

# Verify
railway whoami
```

### Method 2: API Token (Recommended for CI/CD/Teams)

```bash
# 1. Get token from https://railway.app/account/tokens
# 2. Set environment variable
export RAILWAY_TOKEN=your_token_here

# 3. Verify
railway whoami
```

## Team Access

To allow team members to deploy:

```bash
# Add collaborator
railway collaborator add teammate@company.com

# Set role (admin|member|viewer)
railway collaborator add teammate@company.com --role admin
```

## Environment Setup

Create `.env.railway` in your project root:

```bash
RAILWAY_TOKEN=your_token_here
RAILWAY_PROJECT_ID=optional_project_id
```

Then source it:
```bash
source .env.railway
```

## Verification

Run the verification script:
```bash
./scripts/auth.sh
```

## Troubleshooting

**"Not authenticated" error:**
- Run `railway login` again
- Check token hasn't expired at https://railway.app/account/tokens

**"Project not found" error:**
- Run `railway link` to select project
- Or set `RAILWAY_PROJECT_ID`

**Token permissions:**
Ensure token has these scopes:
- `projects:read`
- `projects:write`
- `environments:read`
- `deployments:write`
