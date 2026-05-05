#!/bin/sh
# Deploy script for Plane CE
# Usage: ./scripts/deploy.sh [--with-traefik|--external-traefik] [--env <env>] [--detach|--no-detach]

# Default values
WITH_TRAEFIK=1
ENV="dev"
DETACH="-d"
NETWORK_NAME="plane-network"

# Help message
show_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --with-traefik      Deploy with bundled Traefik proxy"
  echo "  --external-traefik  Deploy without Traefik (use external proxy)"
  echo "  --env <env>         Environment to use (default: dev). Will look for .env.<env>"
  echo "  --no-detach         Run containers in foreground"
  echo "  --detach            Run containers in background (default)"
  echo "  -h, --help          Show this help message"
}

# Function to check if a port is in use
check_port() {
  PORT=$1
  SERVICE=$2
  # Use lsof to get PIDs
  if command -v lsof >/dev/null 2>&1; then
    PIDS=$(lsof -ti :$PORT)
    if [ -z "$PIDS" ]; then
      return 0
    else
      echo "❌ Conflict: Port $PORT (needed by $SERVICE) is already in use."
      for pid in $PIDS; do
        PROCESS=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
        echo "   -> Process: $PROCESS (PID: $pid)"
      done
      return 1
    fi
  elif command -v netstat >/dev/null 2>&1; then
    if netstat -tuln | grep -q ":$PORT "; then
      echo "❌ Conflict: Port $PORT (needed by $SERVICE) is already in use."
      return 1
    fi
  fi
  return 0
}

# Parse arguments
while [ "$1" != "" ]; do
  case "$1" in
    --with-traefik)      WITH_TRAEFIK=1 ;;
    --external-traefik)  WITH_TRAEFIK=0 ;;
    --env)               shift; ENV="$1" ;;
    --no-detach)         DETACH="" ;;
    --detach)            DETACH="-d" ;;
    -h|--help)           show_help; exit 0 ;;
    *)                   echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
  shift
done

echo "🚀 Preparing deployment for environment: $ENV"

# 1. Ensure .env exists
if [ ! -f ".env" ]; then
  if [ -f ".env.$ENV" ]; then
    echo "📝 Copying .env.$ENV to .env"
    cp ".env.$ENV" .env
  elif [ -f ".env.staging" ]; then
    echo "📝 .env.$ENV not found, copying .env.staging to .env"
    cp .env.staging .env
  elif [ -f ".env.example" ]; then
    echo "📝 .env not found, initializing from .env.example"
    cp .env.example .env
    echo "⚠️  WARNING: Using .env.example. Please update .env with real secrets!"
  else
    echo "❌ Error: No .env file found and no template (.env.$ENV, .env.staging, .env.example) exists."
    exit 1
  fi
fi

# 2. Port conflict check
CONFLICT=0
if [ "$WITH_TRAEFIK" -eq 1 ]; then
  check_port 90 "Traefik HTTP" || CONFLICT=1
  check_port 9443 "Traefik HTTPS" || CONFLICT=1
fi

if [ "$CONFLICT" -eq 1 ]; then
  echo "❌ Error: Deployment aborted due to port conflicts."
  echo "👉 Please stop the conflicting services and try again."
  exit 5
fi

# 3. Ensure network exists
if ! docker network ls | grep -q "$NETWORK_NAME"; then
  echo "🌐 Creating docker network: $NETWORK_NAME"
  docker network create "$NETWORK_NAME"
fi

# 4. Ensure required directories exist
echo "📁 Creating required directories..."
mkdir -p ./uploads ./postgres-data ./redis-data ./traefik
if [ "$WITH_TRAEFIK" -eq 1 ]; then
  touch ./traefik/acme.json
  chmod 600 ./traefik/acme.json
fi

# 5. Define compose files
COMPOSE_FILES="-f docker-compose.postgres.yml -f docker-compose.redis.yml -f docker-compose.mq.yml -f docker-compose.minio.yml -f docker-compose.plane.yml"
if [ "$WITH_TRAEFIK" -eq 1 ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.traefik.yml"
fi

# 6. Deployment
echo "📦 Starting stack..."
docker compose $COMPOSE_FILES up $DETACH

if [ $? -eq 0 ]; then
  echo "✅ Deployment successful!"
  if [ "$DETACH" = "-d" ]; then
    echo "🔍 Check status with: docker compose $COMPOSE_FILES ps"
  fi
else
  echo "❌ Deployment failed."
  echo "🔍 Possible reasons:"
  echo "   - Container error: Check logs with 'docker compose $COMPOSE_FILES logs'"
  echo "   - Entrypoint error: Verify 'command' in docker-compose.plane.yml matches the image version."
  echo "   - Connectivity error: Ensure all services share the '$NETWORK_NAME' network."
  exit 1
fi
