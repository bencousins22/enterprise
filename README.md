# 🤖 Agent Zero Enterprise

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template)

Production-ready, scalable deployment of [Agent Zero](https://github.com/agent0ai/agent-zero) with enterprise-grade security, monitoring, and reliability.

## 🚀 Quick Deploy

### Option 1: Railway One-Click (Recommended)
Click the button above to deploy instantly to Railway.

### Option 2: Manual Deploy
```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/agent-zero-enterprise.git
cd agent-zero-enterprise

# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
./scripts/setup.sh
```

## 📦 What's Included

- **High Availability**: Nginx load balancer with 2+ replicas
- **Security**: JWT auth, rate limiting, sandboxed execution
- **Persistence**: PostgreSQL + Redis + Volume storage
- **Monitoring**: Health checks, structured logging, metrics
- **Auto-scaling**: Horizontal scaling support

## 🔧 Architecture

```
┌─────────────────────────────────────────┐
│           Railway Project               │
│  ┌─────────────────────────────────┐   │
│  │      Nginx Load Balancer        │   │
│  └─────────────┬───────────────────┘   │
│                │                        │
│  ┌─────────────┴───────────────────┐   │
│  │    Agent Zero Application       │   │
│  │    (4 Gunicorn Workers)         │   │
│  └─────────────┬───────────────────┘   │
│                │                        │
│    ┌───────────┼───────────┐           │
│    ▼           ▼           ▼           │
│ ┌──────┐  ┌──────┐  ┌──────────┐      │
│ │PostgreSQL│ Redis │ │  Volume  │      │
│ └──────┘  └──────┘  └──────────┘      │
└─────────────────────────────────────────┘
```

## 🛠️ Configuration

### Required Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `RAILWAY_TOKEN` | Railway API token | Yes |
| `OPENAI_API_KEY` | OpenAI API key | Yes |
| `AUTH_SECRET` | JWT secret (auto-generated) | Auto |
| `DATABASE_URL` | PostgreSQL URL (auto) | Auto |
| `REDIS_URL` | Redis URL (auto) | Auto |

### Optional Configuration

```bash
# Performance
WORKERS=4
MAX_CONCURRENT_AGENTS=10

# Security
AUTH_REQUIRED=true
RATE_LIMIT_ENABLED=true
CORS_ORIGINS=https://yourdomain.com

# Features
ENABLE_SUBORDINATES=true
MAX_AGENT_DEPTH=5
```

## 🔒 Security Features

- ✅ JWT Authentication required
- ✅ API key management
- ✅ Rate limiting (10 req/s API)
- ✅ Sandboxed code execution
- ✅ CORS origin restrictions
- ✅ Security headers (XSS, CSRF protection)
- ✅ Encryption at rest & in transit
- ✅ Audit logging

## 📊 Monitoring

- **Health Endpoint**: `GET /health`
- **Logs**: `railway logs`
- **Metrics**: Railway dashboard
- **Errors**: Sentry integration (optional)

## 🧪 Local Development

```bash
# Copy environment
cp .env.example .env
# Edit .env with your API keys

# Start local stack
docker-compose up -d

# Access
# Web UI: http://localhost:3000
# API: http://localhost:50001
```

## 🔄 Updates

```bash
# Pull latest Agent Zero
git submodule update --remote

# Redeploy
railway up
```

## 📚 Documentation

- [Full Deployment Guide](docs/ENTERPRISE_DEPLOY.md)
- [Authentication Setup](docs/AUTH.md)
- [Architecture Overview](docs/ARCHITECTURE.txt)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## 📄 License

MIT - Same as Agent Zero

---

**Note**: This is an enterprise deployment wrapper for [Agent Zero](https://github.com/agent0ai/agent-zero). All core functionality belongs to the original project.
