#!/bin/bash
set -e

echo "🚀 Initializing Agent Zero Enterprise..."
echo "📅 $(date)"
echo "🖥️  Hostname: $(hostname)"

# Set default values for optional variables
export AGENT_NAME="${AGENT_NAME:-Enterprise-Agent}"
export AUTH_SECRET="${AUTH_SECRET:-$(openssl rand -base64 32 2>/dev/null || echo 'default-secret-change-me')}"
export LOG_LEVEL="${LOG_LEVEL:-INFO}"
export WORKERS="${WORKERS:-4}"
export PORT="${PORT:-80}"
export API_PORT="${API_PORT:-50001}"
export MEMORY_BACKEND="${MEMORY_BACKEND:-persistent}"

# Set up data persistence
mkdir -p /app/data/{memory,knowledge,logs,projects}
chmod 755 /app/data
echo "✅ Data directories created"

# Check AI API Keys
if [ -n "$OPENAI_API_KEY" ]; then
    echo "✅ OpenAI API configured"
else
    echo "⚠️  Warning: OPENAI_API_KEY not set"
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
nginx -t && nginx -g "daemon off;" &
NGINX_PID=$!
echo "✅ Nginx started (PID: $NGINX_PID)"

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
echo "API Port:       $API_PORT"
echo "════════════════════════════════════════════════"
echo ""

# Start Agent Zero with enterprise flags
echo "🤖 Starting Agent Zero..."
cd /app

# Find the main entry point
if [ -f "run.py" ]; then
    echo "✅ Found run.py, starting Agent Zero..."
    exec python run.py
elif [ -f "main.py" ]; then
    echo "✅ Found main.py, starting Agent Zero..."
    exec python main.py
elif [ -f "webui/server.py" ]; then
    echo "✅ Found webui/server.py, starting Agent Zero web interface..."
    cd webui
    exec python server.py
elif [ -f "python/run_ui.py" ]; then
    echo "✅ Found python/run_ui.py, starting Agent Zero..."
    cd python
    exec python run_ui.py
else
    echo "❌ Error: Could not find Agent Zero entry point"
    echo "Available files:"
    ls -la /app/
    exit 1
fi
