#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "Checking health for project: $COMPOSE_PROJECT_NAME..."
echo "----------------------------------------------------"

# List of containers to check
CONTAINERS=(
    "platform-postgres"
    "platform-redis"
    "platform-traefik"
    "platform-authentik-server"
    "platform-authentik-worker"
    "platform-plane-backend"
    "platform-plane-worker"
    "platform-plane-beat"
    "platform-plane-frontend"
    "platform-plane-space"
    "platform-plane-admin"
    "platform-plane-live"
    "platform-plane-ai"
)

ALL_HEALTHY=true

for container in "${CONTAINERS[@]}"; do
    # Check if container exists and is running
    STATUS=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)
    
    if [ -z "$STATUS" ]; then
        echo "❌ $container: NOT FOUND"
        ALL_HEALTHY=false
        continue
    fi
    
    if [ "$STATUS" != "running" ]; then
        echo "❌ $container: $STATUS"
        ALL_HEALTHY=false
        continue
    fi
    
    # Check health status if available
    HEALTH=$(docker inspect -f '{{.State.Health.Status}}' "$container" 2>/dev/null)
    
    if [ -n "$HEALTH" ] && [ "$HEALTH" != "healthy" ] && [ "$HEALTH" != "<nil>" ]; then
        echo "⚠️  $container: running (HEALTH: $HEALTH)"
        ALL_HEALTHY=false
    else
        echo "✅ $container: running"
    fi
done

echo -e "\nChecking Infrastructure Connectivity..."
echo "----------------------------------------------------"

# Check Postgres
if docker exec platform-postgres pg_isready -U postgres >/dev/null 2>&1; then
    echo "✅ Postgres: Ready"
else
    echo "❌ Postgres: NOT READY"
    ALL_HEALTHY=false
fi

# Check Redis
if docker exec platform-redis redis-cli ping >/dev/null 2>&1; then
    echo "✅ Redis: Ready"
else
    echo "❌ Redis: NOT READY"
    ALL_HEALTHY=false
fi

echo "----------------------------------------------------"
if [ "$ALL_HEALTHY" = true ]; then
    echo "✅ Containers: All containers are up and healthy."
else
    echo "❌ Containers: Some containers are missing or unhealthy."
fi

echo -e "\nChecking Web Endpoints (HTTP 200 OK)..."
echo "----------------------------------------------------"

check_endpoint() {
    local url=$1
    local name=$2
    # Use -k to allow insecure SSL for local.test
    STATUS_CODE=$(curl -I -s -o /dev/null -w "%{http_code}" -k "$url")
    if [[ "$STATUS_CODE" =~ ^(200|302|308|401)$ ]]; then
        echo "✅ $name ($url): Reachable (Status: $STATUS_CODE)"
    else
        echo "❌ $name ($url): UNREACHABLE (Status: $STATUS_CODE)"
        ALL_HEALTHY=false
    fi
}

# Check based on .env DOMAIN (Testing HTTPS since we have global redirection)
check_endpoint "https://traefik.$DOMAIN/dashboard/" "Traefik Dashboard"
check_endpoint "https://auth.$DOMAIN" "Authentik Login"
check_endpoint "https://app.$DOMAIN" "Plane CE"
check_endpoint "https://app.$DOMAIN/api/health/" "Plane CE API"
check_endpoint "https://ai.$DOMAIN/health/" "Plane AI Service"

echo "----------------------------------------------------"
if [ "$ALL_HEALTHY" = true ]; then
    echo "SUCCESS: Entire system is operational!"
else
    echo "FAILURE: System is not fully operational."
    exit 1
fi
