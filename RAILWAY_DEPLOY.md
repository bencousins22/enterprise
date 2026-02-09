# Agent Zero Enterprise - Railway Deployment Guide

## Quick Deploy to Railway

### Option 1: Deploy via Railway Dashboard (Recommended)

1. **Go to Railway Dashboard**
   - Visit https://railway.app/new
   - Click "Deploy from GitHub repo"

2. **Select Repository**
   - Choose `bencousins22/enterprise`
   - Railway will auto-detect `railway.toml` and `Dockerfile.railway`

3. **Configure Environment Variables**
   
   **Required:**
   ```
   OPENAI_API_KEY=sk-your-openai-api-key
   ```
   
   **Optional:**
   ```
   AGENT_NAME=My-Enterprise-Agent
   LOG_LEVEL=INFO
   ANTHROPIC_API_KEY=sk-ant-your-anthropic-key
   ```

4. **Add Services (Optional)**
   - Redis: For distributed memory/caching
   - PostgreSQL: For persistent data storage
   
   Railway will automatically set `REDIS_URL` and `DATABASE_URL` if you add these services.

5. **Deploy**
   - Click "Deploy"
   - Wait for build to complete (~5-10 minutes)
   - Railway will provide a public URL

### Option 2: Deploy via Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Initialize project
railway init

# Set environment variables
railway variables set OPENAI_API_KEY=sk-your-key

# Deploy
railway up
```

## Configuration

### Environment Variables

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OPENAI_API_KEY` | Yes | - | OpenAI API key for GPT models |
| `AGENT_NAME` | No | Enterprise-Agent | Name of your agent |
| `LOG_LEVEL` | No | INFO | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `WORKERS` | No | 2 | Number of worker processes |
| `PORT` | No | 80 | HTTP port (Railway sets this automatically) |
| `MEMORY_BACKEND` | No | persistent | Memory backend (persistent, redis) |
| `ANTHROPIC_API_KEY` | No | - | Anthropic API key for Claude models |
| `REDIS_URL` | No | - | Redis connection URL (auto-set by Railway) |
| `DATABASE_URL` | No | - | PostgreSQL connection URL (auto-set by Railway) |

### Adding Redis (Recommended)

Redis provides better performance for agent memory and caching:

1. In Railway dashboard, click "New" → "Database" → "Add Redis"
2. Railway automatically sets `REDIS_URL` environment variable
3. The application will automatically use Redis when available

### Adding PostgreSQL (Optional)

For persistent data storage:

1. In Railway dashboard, click "New" → "Database" → "Add PostgreSQL"
2. Railway automatically sets `DATABASE_URL` environment variable

## Architecture

```
┌─────────────────────────────────────────┐
│         Railway Platform                │
│                                         │
│  ┌───────────────────────────────────┐ │
│  │  Nginx (Port 80)                  │ │
│  │  - Rate limiting                  │ │
│  │  - Reverse proxy                  │ │
│  │  - Health checks                  │ │
│  └─────────────┬─────────────────────┘ │
│                │                         │
│  ┌─────────────▼─────────────────────┐ │
│  │  Agent Zero (Port 50001)          │ │
│  │  - Web UI                         │ │
│  │  - API endpoints                  │ │
│  │  - WebSocket support              │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ┌─────────────┐    ┌──────────────┐  │
│  │   Redis     │    │  PostgreSQL  │  │
│  │  (Optional) │    │  (Optional)  │  │
│  └─────────────┘    └──────────────┘  │
└─────────────────────────────────────────┘
```

## Health Check

The deployment includes a health check endpoint at `/health`:

```bash
curl https://your-app.railway.app/health
```

Response:
```json
{
  "status": "healthy",
  "timestamp": "Mon, 09 Feb 2026 10:00:00 GMT",
  "service": "agent-zero-enterprise"
}
```

## Monitoring

View logs in Railway dashboard:
```bash
railway logs
```

Or via CLI:
```bash
railway logs --follow
```

## Troubleshooting

### Build Fails

- Check that all files are committed to GitHub
- Verify Dockerfile.railway exists in repository root
- Check Railway build logs for specific errors

### Application Won't Start

- Verify `OPENAI_API_KEY` is set
- Check application logs in Railway dashboard
- Ensure PORT environment variable is set (Railway does this automatically)

### Connection Issues

- Verify the Railway-provided URL is accessible
- Check health endpoint: `https://your-app.railway.app/health`
- Review Nginx logs for proxy errors

## Scaling

Railway automatically handles:
- Horizontal scaling (multiple instances)
- Load balancing
- SSL/TLS certificates
- CDN for static assets

To scale manually:
1. Go to Railway dashboard
2. Select your service
3. Adjust "Replicas" setting

## Cost Optimization

- Start with 1 replica and 2 workers
- Add Redis only if you need distributed caching
- Monitor usage in Railway dashboard
- Set up usage alerts

## Support

- Railway Documentation: https://docs.railway.app
- Agent Zero GitHub: https://github.com/frdel/agent-zero
- Railway Community: https://discord.gg/railway
