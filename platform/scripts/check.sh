#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    set -a; source .env; set +a
fi

# Setup debug logging directory
DEBUG_LOG_DIR="logs/debug"
mkdir -p "$DEBUG_LOG_DIR"

# Clear old debug logs at start
if [ -d "$DEBUG_LOG_DIR" ]; then
    find "$DEBUG_LOG_DIR" -name "*.log" -delete 2>/dev/null
    echo "🧹 Cleared old debug logs from $DEBUG_LOG_DIR"
fi

# Detect deployment phase from completion marker files (consistent with up.sh)
detect_phase() {
    local root="$PLATFORM_ROOT/.."
    [ -f "$root/PHASE_4_COMPLETION.md" ] && echo "5" && return
    [ -f "$root/PHASE_3_COMPLETION.md" ] && echo "4" && return
    [ -f "$root/PHASE_2_COMPLETION.md" ] && echo "3" && return
    [ -f "$root/PHASE_1_COMPLETION.md" ] && echo "2" && return
    [ -f "$root/DEPLOYMENT_PLAN.md" ]    && echo "1" && return
    echo "0"
}

PHASE=$(detect_phase)

# Containers per phase
# Phase 1-3: Core infrastructure + Plane CE
# Phase 4+: Add AI Service
get_phase_containers() {
    local phase=$1
    local containers=()

    if [ "$phase" -ge 1 ]; then
        containers+=(
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
        )
    fi

    # Phase 4+: AI Service
    if [ "$phase" -ge 4 ]; then
        containers+=("platform-plane-ai")
    fi

    printf '%s\n' "${containers[@]}"
}

# Get containers for current phase
CONTAINERS=($(get_phase_containers "$PHASE"))

echo "🚀 Plane CE Health Check - Phase ${PHASE}"
echo "=========================================="
echo "Project: $COMPOSE_PROJECT_NAME"
echo "Checking: ${#CONTAINERS[@]} services for Phase ${PHASE}"
echo "Time: $(date)"
echo "=========================================="
echo ""

ALL_HEALTHY=true
FAILED_CONTAINERS=()

for container in "${CONTAINERS[@]}"; do
    # Check if container exists and is running
    STATUS=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)

    if [ -z "$STATUS" ]; then
        echo "❌ $container: NOT FOUND"
        ALL_HEALTHY=false
        FAILED_CONTAINERS+=("$container")
        continue
    fi

    if [ "$STATUS" != "running" ]; then
        echo "❌ $container: $STATUS"
        ALL_HEALTHY=false
        FAILED_CONTAINERS+=("$container")

        # Collect logs for failed container
        LOG_FILE="$DEBUG_LOG_DIR/${container}.log"
        docker logs "$container" > "$LOG_FILE" 2>&1
        echo "   📝 Logs saved to: $LOG_FILE"
        continue
    fi

    # Check health status if available
    HEALTH=$(docker inspect -f '{{.State.Health.Status}}' "$container" 2>/dev/null)

    if [ -n "$HEALTH" ] && [ "$HEALTH" != "healthy" ] && [ "$HEALTH" != "<nil>" ]; then
        echo "⚠️  $container: running (HEALTH: $HEALTH)"
        ALL_HEALTHY=false
        FAILED_CONTAINERS+=("$container")

        # Collect logs for unhealthy container
        LOG_FILE="$DEBUG_LOG_DIR/${container}.log"
        docker logs "$container" > "$LOG_FILE" 2>&1
        echo "   📝 Logs saved to: $LOG_FILE"
    else
        echo "✅ $container: running"
    fi
done

echo "📋 Infrastructure Connectivity Check (Phase $PHASE)"
echo "---"

# Check Postgres (Phase 1+)
if [ "$PHASE" -ge 1 ]; then
    if docker exec platform-postgres pg_isready -U postgres >/dev/null 2>&1; then
        echo "✅ PostgreSQL: Ready"
        POSTGRES_USERS=$(docker exec platform-postgres psql -U postgres -tc "SELECT count(*) FROM pg_user;" 2>/dev/null | tr -d ' ')
        echo "   └─ Users in DB: $POSTGRES_USERS"
    else
        echo "❌ PostgreSQL: NOT READY"
        ALL_HEALTHY=false
        LOG_FILE="$DEBUG_LOG_DIR/postgres-connectivity.log"
        docker exec platform-postgres pg_isready -U postgres > "$LOG_FILE" 2>&1
        echo "   📝 Logs saved to: $LOG_FILE"
    fi
fi

# Check Redis (Phase 1+)
if [ "$PHASE" -ge 1 ]; then
    if docker exec platform-redis redis-cli ping >/dev/null 2>&1; then
        echo "✅ Redis: Ready"
        REDIS_KEYS=$(docker exec platform-redis redis-cli dbsize 2>/dev/null | grep -oP '\d+' | head -1)
        echo "   └─ Keys in Redis: $REDIS_KEYS"
    else
        echo "❌ Redis: NOT READY"
        ALL_HEALTHY=false
        LOG_FILE="$DEBUG_LOG_DIR/redis-connectivity.log"
        docker exec platform-redis redis-cli ping > "$LOG_FILE" 2>&1
        echo "   📝 Logs saved to: $LOG_FILE"
    fi
fi

echo "----------------------------------------------------"
if [ "$ALL_HEALTHY" = true ]; then
    echo "✅ Containers: All containers are up and healthy."
else
    echo "❌ Containers: Some containers are missing or unhealthy."
fi

echo -e "\nChecking Web Endpoints (Phase $PHASE)..."
echo "----------------------------------------------------"

check_endpoint() {
    local url=$1
    local name=$2
    local safe_name=$(echo "$name" | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]')
    # Use -k to allow insecure SSL for local.test
    STATUS_CODE=$(curl -I -s -o /dev/null -w "%{http_code}" -k "$url" 2>/dev/null)
    if [[ "$STATUS_CODE" =~ ^(200|302|308|401)$ ]]; then
        echo "✅ $name: Reachable (Status: $STATUS_CODE)"
    else
        echo "❌ $name: UNREACHABLE (Status: $STATUS_CODE)"
        ALL_HEALTHY=false

        # Save endpoint check error
        LOG_FILE="$DEBUG_LOG_DIR/endpoint-${safe_name}.log"
        curl -v -k "$url" > "$LOG_FILE" 2>&1
        echo "   📝 Error details saved to: $LOG_FILE"
    fi
}

# Phase 1+: Core infrastructure endpoints
if [ "$PHASE" -ge 1 ]; then
    check_endpoint "https://traefik.$DOMAIN/dashboard/" "Traefik Dashboard"
    check_endpoint "https://auth.$DOMAIN" "Authentik Login"
    check_endpoint "https://app.$DOMAIN" "Plane CE Frontend"
    check_endpoint "https://app.$DOMAIN/api/instances/" "Plane CE API"
fi

# Phase 4+: AI Service endpoint
if [ "$PHASE" -ge 4 ]; then
    check_endpoint "https://ai.$DOMAIN/health/" "Plane AI Service"
fi

echo ""
echo "🔍 Phase ${PHASE} Specific Checks"
echo "---"

if [ "$PHASE" -ge 1 ]; then
    # Migration container exit status
    MIGRATION_STATUS=$(docker inspect -f '{{.State.Status}}' platform-plane-migration 2>/dev/null)
    MIGRATION_EXIT=$(docker inspect -f '{{.State.ExitCode}}' platform-plane-migration 2>/dev/null)
    if [ "$MIGRATION_STATUS" = "exited" ] && [ "$MIGRATION_EXIT" = "0" ]; then
        echo "✅ Migration Container: Completed successfully"
    elif [ "$MIGRATION_STATUS" = "exited" ] && [ "$MIGRATION_EXIT" != "0" ]; then
        echo "❌ Migration Container: Failed (exit code: $MIGRATION_EXIT)"
        ALL_HEALTHY=false
        docker logs platform-plane-migration > "$DEBUG_LOG_DIR/platform-plane-migration.log" 2>&1
        echo "   📝 Logs saved to: $DEBUG_LOG_DIR/platform-plane-migration.log"
    else
        echo "⚠️  Migration Container: $MIGRATION_STATUS"
    fi

    # Database migrations count
    MIGRATION_COUNT=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc "SELECT count(*) FROM django_migrations;" 2>/dev/null | tr -d ' ')
    echo "✅ Database Migrations: ${MIGRATION_COUNT:-0} executed"

    # plane_ce DB user
    PLANE_USER=$(docker exec platform-postgres psql -U postgres -tc "SELECT count(*) FROM pg_user WHERE usename='plane_ce';" 2>/dev/null | tr -d ' ')
    if [ "${PLANE_USER:-0}" = "1" ]; then
        echo "✅ plane_ce Database User: Created"
    else
        echo "❌ plane_ce Database User: NOT FOUND"
        ALL_HEALTHY=false
    fi

    # Admin user
    ADMIN_COUNT=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc "SELECT count(*) FROM accounts_user WHERE email='admin@plane.local';" 2>/dev/null | tr -d ' ')
    if [ "${ADMIN_COUNT:-0}" -gt 0 ] 2>/dev/null; then
        echo "✅ Admin User (admin@plane.local): Created"
    else
        echo "⚠️  Admin User (admin@plane.local): Not yet created (may appear after first login)"
    fi
fi

echo ""
echo "📊 Summary"
echo "---"
if [ "$ALL_HEALTHY" = true ]; then
    echo "✅ System Status: OPERATIONAL"
    echo ""
    echo "🎯 Next Steps (Phase ${PHASE}):"
    if [ "$PHASE" = "1" ]; then
        echo "  1. Test login: https://app.$DOMAIN"
        echo "  2. Create workspace and project"
        echo "  3. Create test issues"
        echo "  4. Mark Phase 1 complete → PHASE_1_COMPLETION.md"
    elif [ "$PHASE" = "2" ]; then
        echo "  1. Run demo data seeding: cd scripts/seed_demo_plane_ce && python run_all.py"
        echo "  2. Verify demo data in Plane CE"
        echo "  3. Run feature tests"
        echo "  4. Mark Phase 2 complete → PHASE_2_COMPLETION.md"
    elif [ "$PHASE" = "3" ]; then
        echo "  1. Configure Authentik SSO integration"
        echo "  2. Set up custom workflows"
        echo "  3. Configure integrations (email, slack, etc.)"
    elif [ "$PHASE" -ge 4 ]; then
        echo "  1. Configure OpenAI API key in .env"
        echo "  2. Start AI service: START_PLANE_AI=1 ./scripts/up.sh"
        echo "  3. Test AI endpoints: https://ai.$DOMAIN/docs"
    fi
else
    echo "❌ System Status: DEGRADED"
    echo ""
    if [ ${#FAILED_CONTAINERS[@]} -gt 0 ]; then
        echo "⚠️  Failed containers (${#FAILED_CONTAINERS[@]}):"
        for container in "${FAILED_CONTAINERS[@]}"; do
            echo "   • $container"
        done
        echo ""
    fi
    echo "📁 Debug logs saved to: $DEBUG_LOG_DIR/"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "  • View debug logs: cat $DEBUG_LOG_DIR/*.log"
    echo "  • View logs: ./logs.sh <service_name>"
    echo "  • Check containers: docker ps -a"
    echo "  • View error details: cat $DEBUG_LOG_DIR/platform-plane-*.log"
    echo "  • Restart services: docker compose -p platform restart"
    echo ""
    echo "💡 Or run: ./debug.sh 1 <container_name>"
fi
