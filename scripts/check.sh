#!/bin/sh
# Basic system checks before deploy
# Usage: ./scripts/check.sh [--traefik-url <url>]

TRAEFIK_URL=""
NETWORK_NAME="plane-network"

while [ "$1" != "" ]; do
  case "$1" in
    --traefik-url)
      shift; TRAEFIK_URL="$1";;
    -h|--help)
      echo "Usage: $0 [--traefik-url <url>]"
      exit 0;;
  esac
  shift
done

echo "🔍 Running pre-deployment checks..."

# 1. Docker check
echo "🐳 Checking docker availability..."
if ! command -v docker >/dev/null 2>&1; then
  echo "❌ ERROR: docker not installed or not in PATH"
  exit 2
fi

if ! docker info >/dev/null 2>&1; then
  echo "❌ ERROR: cannot talk to docker daemon (is it running?)"
  exit 3
fi

# 2. Compose files check
echo "📄 Checking required compose files..."
MISSING=0
for f in docker-compose.postgres.yml docker-compose.redis.yml docker-compose.plane.yml; do
  if [ ! -f "$f" ]; then
    echo "❗ Missing $f"
    MISSING=1
  fi
done

if [ "$MISSING" -eq 1 ]; then
  echo "❌ Error: One or more compose files are missing."
  exit 4
fi

# 3. Port conflict check
echo "🔌 Checking port availability..."
check_port() {
  PORT=$1
  SERVICE=$2
  if command -v lsof >/dev/null 2>&1; then
    PIDS=$(lsof -ti :$PORT)
    if [ -n "$PIDS" ]; then
      echo "❌ ERROR: Port $PORT ($SERVICE) is in use:"
      for pid in $PIDS; do
        PROCESS=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
        echo "   -> $PROCESS (PID: $pid)"
      done
      return 1
    fi
  fi
  echo "✅ Port $PORT is available"
  return 0
}

check_port 90 "HTTP"
check_port 9443 "HTTPS"

# 4. Environment check
echo "📝 Checking environment configuration..."
if [ ! -f ".env" ]; then
  echo "⚠️  WARNING: No .env file found. Running deploy.sh will attempt to initialize it."
else
  echo "✅ .env file found."
fi

# 5. Network check
echo "🌐 Checking docker network..."
if ! docker network ls | grep -q "$NETWORK_NAME"; then
  echo "⚠️  WARNING: Network '$NETWORK_NAME' does not exist. deploy.sh will create it."
else
  echo "✅ Network '$NETWORK_NAME' exists."
fi

echo "✨ All checks completed."
exit 0
