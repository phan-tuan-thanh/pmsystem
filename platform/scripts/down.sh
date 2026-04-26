#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROJECT_ROOT="$(cd "$PLATFORM_ROOT/.." && pwd)"

cd "$PLATFORM_ROOT"

if [ -f .env ]; then
    set -a; source .env; set +a
fi

# Detect deployment phase
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
CLEAN_FLAG=""
for arg in "$@"; do
    case $arg in
        --clean) CLEAN_FLAG="--volumes" ;;
        *) echo "Unknown option: $arg" && echo "Usage: $0 [--clean]" && exit 1 ;;
    esac
done

if [ -n "$CLEAN_FLAG" ]; then
    echo "⚠️  --clean: volumes will be removed (all data will be lost)"
fi

echo "Stopping services (Phase $CURRENT_PHASE)..."

# Stop plane-ai only if it's Phase 4+ or the container actually exists/running
if [ "$CURRENT_PHASE" -ge 4 ] || docker ps -q -f "name=platform-plane-ai" | grep -q .; then
    echo "  Stopping Plane AI..."
    docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f plane-ai/docker-compose.yml down $CLEAN_FLAG
fi

echo "  Stopping Plane CE..."
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f plane-ce/docker-compose.yml down $CLEAN_FLAG

echo "  Stopping Authentik..."
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f authentik/docker-compose.yml down $CLEAN_FLAG

echo "  Stopping Traefik..."
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f traefik/docker-compose.yml down $CLEAN_FLAG

echo "  Stopping Redis..."
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f redis/docker-compose.yml down $CLEAN_FLAG

echo "  Stopping Postgres..."
docker compose -p "$COMPOSE_PROJECT_NAME" --env-file .env -f postgres/docker-compose.yml down $CLEAN_FLAG

if [ -n "$CLEAN_FLAG" ]; then
    echo "All services stopped and volumes removed."
else
    echo "All services stopped."
fi
