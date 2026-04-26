#!/bin/bash

# Debug script for troubleshooting Plane CE deployment
# Usage: ./debug.sh [phase] [service]
# Examples:
#   ./debug.sh          → debug all Phase 1 services
#   ./debug.sh 1 backend
#   ./debug.sh 1 worker
#   ./debug.sh 1 migration
#   ./debug.sh 1 traefik

PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
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
PHASE=${1:-$CURRENT_PHASE}
SERVICE=${2:-}

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Plane CE Debug & Troubleshooting Tool             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo "Deployment Phase: $CURRENT_PHASE | Debugging Phase: $PHASE"
echo "Service filter: ${SERVICE:-all}"
echo "Time: $(date)"
echo ""

# ── Helpers ───────────────────────────────────────────────────────────

check_container() {
    local container=$1
    local exists
    exists=$(docker ps -a --format "{{.Names}}" | grep -c "^${container}$" 2>/dev/null || echo 0)

    if [ "$exists" -eq 0 ]; then
        echo "  ❌ $container: NOT FOUND"
        return 1
    fi

    local status restarts
    status=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)
    restarts=$(docker inspect -f '{{.RestartCount}}' "$container" 2>/dev/null)
    local health
    health=$(docker inspect -f '{{.State.Health.Status}}' "$container" 2>/dev/null)

    if [ "$status" = "running" ]; then
        local health_str=""
        [ -n "$health" ] && [ "$health" != "<nil>" ] && health_str=" | health: $health"
        echo "  ✅ $container: running (restarts: $restarts$health_str)"
    elif [ "$status" = "exited" ]; then
        local exit_code
        exit_code=$(docker inspect -f '{{.State.ExitCode}}' "$container" 2>/dev/null)
        echo "  ⚠️  $container: exited (code: $exit_code)"
    else
        echo "  ❌ $container: $status (restarts: $restarts)"
        return 1
    fi
}

show_logs() {
    local container=$1
    local lines=${2:-40}
    echo ""
    echo "  📋 Last $lines lines of $container:"
    echo "  ─────────────────────────────────────────────"
    docker logs --tail "$lines" "$container" 2>&1 | sed 's/^/  /'
    echo ""
}

# ── Phase 1 Debugging ─────────────────────────────────────────────────

if [ "$PHASE" = "1" ] || [ "$PHASE" = "2" ]; then

    # ── Backend ──────────────────────────────────────────────────────
    if [ -z "$SERVICE" ] || [ "$SERVICE" = "backend" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Backend (plane-backend)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-plane-backend"

        echo ""
        echo "  🌐 API Health Check:"
        API_CODE=$(curl -s -o /dev/null -w "%{http_code}" -k "https://app.${DOMAIN:-local.test}/api/health/" 2>/dev/null)
        echo "    https://app.${DOMAIN:-local.test}/api/health/ → HTTP $API_CODE"
        if [ "$API_CODE" != "200" ]; then
            echo "    ⚠️  API not responding with 200 — check logs below"
        fi

        show_logs "platform-plane-backend" 50
    fi

    # ── Migration ────────────────────────────────────────────────────
    if [ -z "$SERVICE" ] || [ "$SERVICE" = "migration" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Database Migration (plane-migration)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-plane-migration"

        MIGRATION_EXIT=$(docker inspect -f '{{.State.ExitCode}}' platform-plane-migration 2>/dev/null)
        if [ "$MIGRATION_EXIT" = "0" ]; then
            echo "  ✅ Migration completed successfully"
            MIGRATION_COUNT=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc \
                "SELECT count(*) FROM django_migrations;" 2>/dev/null | tr -d ' ')
            echo "  📊 Migrations applied: ${MIGRATION_COUNT:-unknown}"
        else
            echo "  ❌ Migration failed (exit: $MIGRATION_EXIT)"
            show_logs "platform-plane-migration" 60
        fi
    fi

    # ── Worker ───────────────────────────────────────────────────────
    if [ -z "$SERVICE" ] || [ "$SERVICE" = "worker" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Celery Worker (plane-worker)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-plane-worker"
        show_logs "platform-plane-worker" 40

        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Celery Beat (plane-beat)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-plane-beat"
        show_logs "platform-plane-beat" 20
    fi

    # ── PostgreSQL ───────────────────────────────────────────────────
    if [ -z "$SERVICE" ] || [ "$SERVICE" = "postgres" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 PostgreSQL"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-postgres"

        if docker ps --format "{{.Names}}" | grep -q "platform-postgres"; then
            echo ""
            echo "  🗄️  Databases:"
            docker exec platform-postgres psql -U postgres -c "\l" 2>/dev/null | grep -E "plane|authentik" | sed 's/^/    /'
            echo ""
            echo "  👥 Users:"
            docker exec platform-postgres psql -U postgres -tc \
                "SELECT usename FROM pg_user;" 2>/dev/null | grep -v "^$" | sed 's/^/    /'
        fi
    fi

    # ── Redis ─────────────────────────────────────────────────────────
    if [ -z "$SERVICE" ] || [ "$SERVICE" = "redis" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Redis"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-redis"

        if docker ps --format "{{.Names}}" | grep -q "platform-redis"; then
            echo ""
            echo "  📊 Redis info:"
            docker exec platform-redis redis-cli info server 2>/dev/null | grep "redis_version" | sed 's/^/    /'
            KEYS=$(docker exec platform-redis redis-cli dbsize 2>/dev/null)
            echo "    Keys: $KEYS"
        fi
    fi

    # ── Traefik ───────────────────────────────────────────────────────
    if [ -z "$SERVICE" ] || [ "$SERVICE" = "traefik" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Traefik Routing"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-traefik"
        echo ""
        echo "  🌐 Endpoint checks:"
        for endpoint_info in \
            "https://app.${DOMAIN:-local.test}/|Plane CE Frontend" \
            "https://app.${DOMAIN:-local.test}/api/health/|Plane CE API" \
            "https://traefik.${DOMAIN:-local.test}/dashboard/|Traefik Dashboard"; do
            url="${endpoint_info%%|*}"
            name="${endpoint_info##*|}"
            code=$(curl -s -o /dev/null -w "%{http_code}" -k "$url" 2>/dev/null)
            if echo "$code" | grep -qE "^(200|301|302|308|401)"; then
                echo "    ✅ $name ($code)"
            else
                echo "    ❌ $name ($code)"
            fi
        done
    fi

    # ── Frontend ──────────────────────────────────────────────────────
    if [ "$SERVICE" = "frontend" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Frontend (plane-frontend)"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        check_container "platform-plane-frontend"
        show_logs "platform-plane-frontend" 40
    fi

fi

# ── Phase 2 Debugging ─────────────────────────────────────────────────

if [ "$PHASE" = "2" ] || [ "$CURRENT_PHASE" = "2" ]; then
    if [ -z "$SERVICE" ] || [ "$SERVICE" = "seeding" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📍 Phase 2: Demo Data Status"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        if docker exec platform-postgres pg_isready -U postgres >/dev/null 2>&1; then
            USERS=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc \
                "SELECT count(*) FROM accounts_user;" 2>/dev/null | tr -d ' ')
            PROJECTS=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc \
                "SELECT count(*) FROM projects_project;" 2>/dev/null | tr -d ' ')
            ISSUES=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc \
                "SELECT count(*) FROM db_issue;" 2>/dev/null | tr -d ' ')
            echo "  Users:    ${USERS:-0} (target: 30)"
            echo "  Projects: ${PROJECTS:-0} (target: 20)"
            echo "  Issues:   ${ISSUES:-0} (target: ~1000)"
        else
            echo "  ❌ Cannot connect to database"
        fi
    fi
fi

# ── Summary ───────────────────────────────────────────────────────────

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📚 Quick Commands:"
echo "  Full health check:   ./scripts/check.sh"
echo "  View phase progress: ./scripts/phase-progress.sh"
echo "  View service logs:   ./scripts/logs.sh <service>"
echo "  Restart services:    docker compose -p platform -f plane-ce/docker-compose.yml restart"
echo "  Migration logs:      docker logs platform-plane-migration"
echo ""
