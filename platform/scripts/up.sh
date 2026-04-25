#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Set the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Change to the platform root so that relative paths in .env and compose files work
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

# Check if hostnames are mapped in /etc/hosts (crucial for local dev)
if [ ! -z "$DOMAIN" ]; then
    # Check if key hostnames are mapped to 127.0.0.1
    REQUIRED_HOSTS=("traefik.$DOMAIN" "app.$DOMAIN" "ai.$DOMAIN")
    MISSING_HOSTS=false

    for HOST in "${REQUIRED_HOSTS[@]}"; do
        if ! grep -q "^127.0.0.1.*$HOST" /etc/hosts; then
            echo "❌ Hostname $HOST not found in /etc/hosts"
            MISSING_HOSTS=true
        fi
    done

    if [ "$MISSING_HOSTS" = true ]; then
        echo ""
        echo "⚠️  Some required hostnames are missing from /etc/hosts"
        echo "Attempting to update /etc/hosts automatically..."
        sudo ./scripts/setup-hosts.sh
    else
        echo "✓ All required hostnames found in /etc/hosts"
    fi
fi

# Create proxy network if not exists
docker network inspect proxy >/dev/null 2>&1 || \
    docker network create proxy

# Start core services
echo "Starting Postgres..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f postgres/docker-compose.yml up -d
echo "Starting Redis..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f redis/docker-compose.yml up -d
echo "Starting Traefik..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f traefik/docker-compose.yml up -d

# Function to wait for a container to be healthy
wait_for_healthy() {
    local container_name=$1
    echo "Waiting for $container_name to be healthy..."
    until [ "$(docker inspect -f {{.State.Health.Status}} $container_name 2>/dev/null)" == "healthy" ]; do
        echo -n "."
        sleep 2
    done
    echo " [OK]"
}

wait_for_healthy platform-postgres
wait_for_healthy platform-redis

echo "Starting Authentik..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f authentik/docker-compose.yml up -d

echo "Starting Plane CE..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f plane-ce/docker-compose.yml up -d

echo "Starting Plane AI Service..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f plane-ai/docker-compose.yml up -d

# Wait for Plane CE HTTP server to be up before considering deployment complete
echo "Waiting for Plane CE to be ready..."
RETRIES=60
until curl -k -s -o /dev/null -w "%{http_code}" "https://app.$DOMAIN/api/health/" | grep -qE "^(200|302)"; do
    RETRIES=$((RETRIES - 1))
    if [ "$RETRIES" -le 0 ]; then
        echo ""
        echo "⚠️  Plane CE did not become ready in time. Check logs with: ./scripts/logs.sh plane-backend"
        break
    fi
    echo -n "."
    sleep 3
done
echo ""

echo "✅ Deployment complete!"
echo ""
echo "Access your services at:"
echo "  Plane CE  : https://app.$DOMAIN"
echo "  Plane AI  : https://ai.$DOMAIN"
echo "  Authentik : https://auth.$DOMAIN"
echo "  Traefik   : https://traefik.$DOMAIN/dashboard/"
echo ""
echo "Default Plane CE credentials: $PLANE_ADMIN_EMAIL / $PLANE_ADMIN_PASSWORD"
