# Agent Zero Enterprise Deployment Guide

## 🎯 Overview

This enterprise deployment package provides a production-ready, scalable Agent Zero instance optimized for Railway hosting with enterprise-grade security, monitoring, and reliability features.

## 📁 Package Contents

```
agent-zero-enterprise/
├── Dockerfile.railway       # Optimized container build
├── railway.toml            # Railway platform configuration
├── docker-compose.yml      # Local development stack
├── start.sh                # Container initialization script
├── nginx.conf              # Reverse proxy & load balancer
├── .env.example            # Environment variable template
├── scripts/
│   ├── setup.sh           # One-click deployment script
│   └── healthcheck.sh     # Health monitoring utility
└── docs/
    └── ENTERPRISE_DEPLOY.md # This file
```

## 🚀 Quick Start (One Command Deploy)

```bash
# 1. Clone this setup
cd agent-zero-enterprise

# 2. Run deployment
./scripts/setup.sh my-company-agent development

# 3. Follow prompts to add API keys
```

## 🏗️ Architecture

### Infrastructure Stack
- **Container**: Docker with multi-layer optimization
- **Reverse Proxy**: Nginx with rate limiting and caching
- **Application**: Agent Zero with enterprise flags
- **Database**: PostgreSQL (persistent storage)
- **Cache**: Redis (session & memory backend)
- **Volume**: Persistent disk for knowledge base & logs

### Security Features
- JWT-based authentication required
- API key management
- Rate limiting (10 req/s API, 50 req/s general)
- CORS origin restrictions
- Security headers (XSS, CSRF, Clickjacking protection)
- Sandboxed code execution
- Audit logging
- Encryption at rest

### Scalability
- Horizontal scaling with Railway replicas
- Redis-backed session persistence
- Connection pooling (32 keepalive connections)
- Worker process configuration (4 default)
- Load balancing via Nginx upstream

## ⚙️ Configuration

### Required Environment Variables

```bash
# AI Providers (at least one required)
OPENAI_API_KEY=sk-proj-...           # OpenAI API
ANTHROPIC_API_KEY=sk-ant-...         # Anthropic (optional)

# Security (auto-generated if not set)
AUTH_SECRET=random-jwt-secret-32+chars
ADMIN_USERNAME=admin
ADMIN_PASSWORD_HASH=bcrypt-hash

# Railway (auto-injected by platform)
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
PORT=80
RAILWAY_ENVIRONMENT=production
```

### Optional Configuration

```bash
# Agent Behavior
MAX_AGENT_DEPTH=5                    # Max hierarchy depth
MAX_SUBORDINATES_PER_AGENT=3         # Spawn limit per agent
ENABLE_SUBORDINATES=true             # Allow agent spawning
DEFAULT_AGENT_MODEL=gpt-4            # Default LLM

# Performance
WORKERS=4                            # Gunicorn workers
MAX_CONCURRENT_AGENTS=10             # Concurrent limit
WEB_CONCURRENCY=4                    # Thread workers

# Compliance
GDPR_COMPLIANCE=true                 # GDPR mode
DATA_RETENTION_DAYS=90               # Auto-cleanup
AUDIT_LOG_ENABLED=true               # Access logging
```

## 🔒 Security Checklist

Before production deployment:

- [ ] Change default `AUTH_SECRET` (min 32 chars)
- [ ] Set strong admin password (bcrypt hashed)
- [ ] Configure CORS to specific domains only
- [ ] Enable audit logging
- [ ] Set up Sentry for error tracking
- [ ] Configure rate limiting values
- [ ] Review `ALLOWED_TOOLS` list
- [ ] Disable SSH (`ENABLE_SSH=false`)
- [ ] Enable sandbox mode (`SANDBOX_MODE=true`)
- [ ] Set resource limits (CPU/memory)
- [ ] Enable Railway deployment protection
- [ ] Configure backup schedules

## 🧪 Local Development

Test locally before deploying:

```bash
# 1. Set environment
cp .env.example .env
# Edit .env with your API keys

# 2. Start stack
docker-compose up -d

# 3. Access services
# Web UI: http://localhost:3000
# API: http://localhost:50001

# 4. View logs
docker-compose logs -f agent-zero

# 5. Stop
docker-compose down -v
```

## 📊 Monitoring

### Health Checks
- **Endpoint**: `GET /health`
- **Response**: `{"status":"healthy","timestamp":"..."}`
- **Railway**: Automatic health monitoring every 30s

### Logs
- **Application**: `/app/logs/agent.log`
- **Audit**: `/app/logs/audit.log`
- **Nginx**: `/var/log/nginx/access.log`
- **Railway**: `railway logs` command

### Metrics
- Prometheus endpoint: `/metrics` (if enabled)
- Railway dashboard resource monitoring
- Custom Sentry integration for errors

## 🔄 Updates & Maintenance

### Updating Agent Zero

```bash
# Pull latest changes
git pull origin development

# Rebuild and deploy
railway up

# Or zero-downtime deployment
railway up --detach
```

### Backup & Recovery

Railway provides automatic backups for:
- **PostgreSQL**: Point-in-time recovery
- **Volumes**: Daily snapshots

Manual backup:
```bash
# Export knowledge base
railway run -- tar -czf /tmp/backup.tar.gz /app/data
railway download /tmp/backup.tar.gz
```

## 🆘 Troubleshooting

### Common Issues

**Container won't start:**
```bash
railway logs
# Check for missing env vars or port conflicts
```

**Database connection failed:**
- Verify `DATABASE_URL` is set
- Check PostgreSQL service status in Railway dashboard

**Redis connection failed:**
- Falls back to persistent mode automatically
- Check `REDIS_URL` format

**Out of memory:**
- Increase Railway plan resources
- Reduce `MAX_CONCURRENT_AGENTS`
- Check for memory leaks in logs

### Support Resources

- **Agent Zero Docs**: https://github.com/agent0ai/agent-zero
- **Railway Docs**: https://docs.railway.app
- **Logs**: `railway logs --tail 100`

## 📈 Enterprise Features

### Multi-Agent Orchestration
- Hierarchical agent management (max depth: 5)
- Subordinate spawning with resource quotas
- Inter-agent communication via Redis pub/sub
- Centralized logging across agent tree

### Compliance
- GDPR-compliant data handling
- Configurable data retention (default 90 days)
- Audit trail for all actions
- Right to erasure support

### Integration
- RESTful API with OpenAPI docs
- WebSocket support for real-time updates
- Webhook support for external notifications
- Custom tool registration

---

**Version**: 1.0.0-enterprise  
**Last Updated**: 2024  
**Maintainer**: Your DevOps Team
