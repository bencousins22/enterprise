#!/bin/bash
set -e

echo "🚀 Initializing Agent Zero Enterprise..."
echo "📅 $(date)"
echo "🖥️  Hostname: $(hostname)"

# Validate required environment variables
required_vars=("AGENT_NAME" "AUTH_SECRET")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [ -z "${!var}" ]; then
        missing_vars+=("$var")
    fi
done

if [ ${#missing_vars[@]} -ne 0 ]; then
    echo "❌ Error: Missing required environment variables: ${missing_vars[*]}"
    exit 1
fi

# Set up data persistence
mkdir -p /app/data/{memory,knowledge,logs,projects}
chmod 755 /app/data
echo "✅ Data directories created"

# Check AI API Keys
if [ -n "$OPENAI_API_KEY" ]; then
    echo "✅ OpenAI API configured"
fi

if [ -n "$ANTHROPIC_API_KEY" ]; then
    echo "✅ Anthropic API configured"
fi

# Configure Redis if available (Railway Redis)
if [ -n "$REDIS_URL" ]; then
    echo "✅ Redis detected at: ${REDIS_URL//:*@/:***@}"
    export MEMORY_BACKEND=redis
    # Test connection
    if redis-cli -u "$REDIS_URL" ping > /dev/null 2>&1; then
        echo "✅ Redis connection successful"
    else
        echo "⚠️  Warning: Redis connection failed, falling back to persistent"
        export MEMORY_BACKEND=persistent
    fi
fi

# Configure PostgreSQL if available
if [ -n "$DATABASE_URL" ]; then
    echo "✅ Database detected"
    export DB_URL="$DATABASE_URL"
fi

# Start Nginx reverse proxy
echo "🌐 Starting Nginx..."
nginx -t && service nginx start

# Log configuration summary
echo ""
echo "════════════════════════════════════════════════"
echo "   Agent Zero Enterprise Configuration"
echo "════════════════════════════════════════════════"
echo "Agent Name:     $AGENT_NAME"
echo "Memory Backend: $MEMORY_BACKEND"
echo "Log Level:      $LOG_LEVEL"
echo "Workers:        $WORKERS"
echo "Port:           $PORT"
echo "════════════════════════════════════════════════"
echo ""

# Start Agent Zero with enterprise flags
echo "🤖 Starting Agent Zero..."
cd /app

# Check if main.py exists (fallback to docker-entrypoint if not)
if [ -f "main.py" ]; then
    exec python main.py \
        --mode=enterprise \
        --port="${PORT:-80}" \
        --api-port="${API_PORT:-50001}" \
        --workers="${WORKERS:-4}" \
        --log-level="${LOG_LEVEL:-INFO}"
else
    echo "⚠️  main.py not found, using default entrypoint"
    exec /app/docker-entrypoint.sh
fi
