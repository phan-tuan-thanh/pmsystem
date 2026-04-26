#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PLATFORM_ROOT/.." && pwd)"

cd "$PLATFORM_ROOT"

if [ -f .env ]; then
    set -a; source .env; set +a
fi

# Detect deployment phase from completion marker files
detect_phase() {
    [ -f "$PROJECT_ROOT/PHASE_4_COMPLETION.md" ] && echo "5" && return
    [ -f "$PROJECT_ROOT/PHASE_3_COMPLETION.md" ] && echo "4" && return
    [ -f "$PROJECT_ROOT/PHASE_2_COMPLETION.md" ] && echo "3" && return
    [ -f "$PROJECT_ROOT/PHASE_1_COMPLETION.md" ] && echo "2" && return
    [ -f "$PROJECT_ROOT/DEPLOYMENT_PLAN.md" ]    && echo "1" && return
    echo "0"
}

CURRENT_PHASE=$(detect_phase)

# ── Parse arguments ──────────────────────────────────────────────────
BUILD_FLAG=""
for arg in "$@"; do
    case $arg in
        --build) BUILD_FLAG="--build" ;;
        *) echo "Unknown option: $arg" && echo "Usage: $0 [--build]" && exit 1 ;;
    esac
done

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Plane CE Deployment - Phase $CURRENT_PHASE                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "Project: $COMPOSE_PROJECT_NAME | Domain: $DOMAIN${BUILD_FLAG:+ | Mode: rebuild}"
echo ""

# Check /etc/hosts for required hostnames
if [ -n "$DOMAIN" ]; then
    REQUIRED_HOSTS=("traefik.$DOMAIN" "auth.$DOMAIN" "app.$DOMAIN" "space.$DOMAIN" "admin.$DOMAIN")
    [ "$CURRENT_PHASE" -ge 4 ] && REQUIRED_HOSTS+=("ai.$DOMAIN")
    MISSING_HOSTS=false

    for HOST in "${REQUIRED_HOSTS[@]}"; do
        if ! grep -q "^127.0.0.1.*$HOST" /etc/hosts; then
            echo "❌ Hostname $HOST not found in /etc/hosts"
            MISSING_HOSTS=true
        fi
    done

    if [ "$MISSING_HOSTS" = true ]; then
        echo "⚠️  Missing hostnames — updating /etc/hosts automatically..."
        sudo ./scripts/setup-hosts.sh
    else
        echo "✅ All required hostnames found in /etc/hosts"
    fi
fi

# Create proxy network if not exists
docker network inspect proxy >/dev/null 2>&1 || docker network create proxy

# ── Pre-flight: filesystem prerequisites ─────────────────────────────
echo "▶ Pre-flight checks..."

# Traefik letsencrypt dir + acme.json must exist with 600 permissions
# Traefik refuses to start if acme.json is world-readable (666/664)
mkdir -p traefik/letsencrypt
ACME_JSON="traefik/letsencrypt/acme.json"
[ -f "$ACME_JSON" ] || touch "$ACME_JSON"
chmod 600 "$ACME_JSON"
echo "  ✅ traefik/letsencrypt/acme.json → permissions 600"

# Plane CE log/data dirs expected by bind mounts
mkdir -p plane-ce/logs plane-ce/data
echo "  ✅ plane-ce/logs, plane-ce/data created"

# Plane AI log dir
mkdir -p plane-ai/logs
echo "  ✅ plane-ai/logs created"

# Debug log dir for check.sh / diagnose.sh
mkdir -p logs/debug
echo "  ✅ logs/debug created"

# Wait for a container to become healthy
wait_for_healthy() {
    local container_name=$1
    local timeout=${2:-120}
    local elapsed=0
    echo -n "Waiting for $container_name to be healthy..."
    until [ "$(docker inspect -f '{{.State.Health.Status}}' "$container_name" 2>/dev/null)" = "healthy" ]; do
        elapsed=$((elapsed + 2))
        if [ $elapsed -ge $timeout ]; then
            echo " TIMEOUT ⚠️"
            return 1
        fi
        echo -n "."
        sleep 2
    done
    echo " ✅"
}

# ── Phase 1.1: Infrastructure ────────────────────────────────────────
echo ""
echo "▶ Phase 1.1: Starting infrastructure..."
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f postgres/docker-compose.yml up -d $BUILD_FLAG
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f redis/docker-compose.yml up -d $BUILD_FLAG
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f traefik/docker-compose.yml up -d $BUILD_FLAG

wait_for_healthy platform-postgres
wait_for_healthy platform-redis

docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f authentik/docker-compose.yml up -d $BUILD_FLAG
echo "  ✅ Infrastructure started (Postgres, Redis, Traefik, Authentik)"

# ── Phase 1.2: Plane CE Core ─────────────────────────────────────────
echo ""
echo "▶ Phase 1.2: Starting Plane CE core services..."
docker rm platform-plane-migration 2>/dev/null || true
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f plane-ce/docker-compose.yml up -d $BUILD_FLAG

# Wait for migration container to exit (success or failure)
echo -n "  Waiting for database migration..."
MIGRATION_TIMEOUT=0
until [ "$(docker inspect -f '{{.State.Status}}' platform-plane-migration 2>/dev/null)" = "exited" ]; do
    MIGRATION_TIMEOUT=$((MIGRATION_TIMEOUT + 2))
    if [ $MIGRATION_TIMEOUT -ge 180 ]; then
        echo " TIMEOUT ⚠️"
        echo "  Migration is taking too long. Check: docker logs platform-plane-migration"
        break
    fi
    echo -n "."
    sleep 2
done

MIGRATION_EXIT=$(docker inspect -f '{{.State.ExitCode}}' platform-plane-migration 2>/dev/null)
if [ "$MIGRATION_EXIT" = "0" ]; then
    echo " ✅"
else
    echo " ❌ (exit code: $MIGRATION_EXIT)"
    echo "  ⚠️  Migration failed — backend may not start correctly."
    echo "  Check: docker logs platform-plane-migration"
fi

# ── Phase 4: AI Service (only when explicitly needed) ────────────────
if [ "$CURRENT_PHASE" -ge 4 ] || [ "${START_PLANE_AI:-0}" = "1" ]; then
    echo ""
    echo "▶ Phase 4: Starting Plane AI Service..."
    docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f plane-ai/docker-compose.yml up -d $BUILD_FLAG
    echo "  ✅ Plane AI Service started"
fi

# ── Wait for Plane CE API to be ready ───────────────────────────────
echo ""
echo "▶ Waiting for Plane CE API to be ready..."
RETRIES=90
until curl -k -s -o /dev/null -w "%{http_code}" "https://app.$DOMAIN/api/instances/" | grep -qE "^(200|302)"; do
    RETRIES=$((RETRIES - 1))
    if [ "$RETRIES" -le 0 ]; then
        echo ""
        echo "⚠️  Plane CE API did not become ready in time."
        echo "  Check: ./scripts/logs.sh plane-backend"
        echo "  Debug: ./scripts/debug.sh 1 backend"
        break
    fi
    echo -n "."
    sleep 3
done
echo ""

echo "✅ Deployment complete! (Phase $CURRENT_PHASE)"
echo ""
echo "Access:"
echo "  Plane CE  : https://app.$DOMAIN"
echo "  Authentik : https://auth.$DOMAIN"
echo "  Traefik   : https://traefik.$DOMAIN/dashboard/"
[ "$CURRENT_PHASE" -ge 4 ] && echo "  Plane AI  : https://ai.$DOMAIN"
echo ""
echo "Credentials: $PLANE_ADMIN_EMAIL / $PLANE_ADMIN_PASSWORD"
echo ""
echo "Next: ./scripts/check.sh"
