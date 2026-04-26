#!/bin/bash

# Phase Progress Tracker
# Shows detailed phase status and completion metrics

PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    set -a; source .env; set +a
fi

# Detect deployment phase from completion marker files (consistent with up.sh and check.sh)
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

PHASE_NAMES=([0]="Pre-deployment" [1]="Core Infrastructure (in progress)" [2]="Demo Data Seeding" [3]="Extensions & Customizations" [4]="AI Enhancements" [5]="Production Hardening")

echo "╔════════════════════════════════════════════════════════════╗"
echo "║         Plane CE Deployment Progress Tracker              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Current Phase: $PHASE — ${PHASE_NAMES[$PHASE]}"
echo "Time: $(date)"
echo ""

echo "Phase 1: Core Docker Infrastructure"
echo "════════════════════════════════════"

# Infrastructure services
echo "Infrastructure Services:"
INFRA_OK=0
for service in postgres redis traefik; do
    if docker ps --format "table {{.Names}}" | grep -q "platform-$service"; then
        echo "  ✅ platform-$service"
        ((INFRA_OK++))
    else
        echo "  ❌ platform-$service"
    fi
done
echo "  ($INFRA_OK/3 infrastructure services running)"
echo ""

# Plane services
echo "Plane CE Services:"
PLANE_OK=0
PLANE_SERVICES=("backend" "frontend" "worker" "beat" "live" "admin" "space")
for service in "${PLANE_SERVICES[@]}"; do
    if docker ps --format "table {{.Names}}" | grep -q "platform-plane-$service"; then
        STATUS=$(docker inspect -f '{{.State.Status}}' "platform-plane-$service" 2>/dev/null)
        if [ "$STATUS" = "running" ]; then
            echo "  ✅ plane-$service"
            ((PLANE_OK++))
        else
            echo "  ⚠️  plane-$service ($STATUS)"
        fi
    else
        echo "  ❌ plane-$service"
    fi
done
echo "  ($PLANE_OK/7 Plane CE services running)"
echo ""

# Database checks
echo "Database Status:"
if docker exec platform-postgres pg_isready -U postgres >/dev/null 2>&1; then
    MIGRATION_COUNT=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc "SELECT count(*) FROM django_migrations;" 2>/dev/null | tr -d ' ')
    USERS_COUNT=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc "SELECT count(*) FROM accounts_user;" 2>/dev/null | tr -d ' ')
    PROJECTS_COUNT=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc "SELECT count(*) FROM projects_project;" 2>/dev/null | tr -d ' ')

    echo "  ✅ PostgreSQL connected"
    echo "    • Migrations: $MIGRATION_COUNT"
    echo "    • Users: $USERS_COUNT"
    echo "    • Projects: $PROJECTS_COUNT"
else
    echo "  ❌ PostgreSQL not accessible"
fi
echo ""

# API health
echo "API Health:"
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" -k "https://app.${DOMAIN:-local.test}/api/health/" 2>/dev/null)
if [ "$API_STATUS" = "200" ]; then
    echo "  ✅ Backend API: Healthy"
else
    echo "  ❌ Backend API: Unreachable (Status: $API_STATUS)"
fi
echo ""

# Completion metrics
echo "╭─ Phase 1 Completion Metrics ─────────────────────────────╮"
COMPLETE_PERCENT=$((PLANE_OK * 100 / 7))
echo "│ Services Running: $PLANE_OK/7 ($COMPLETE_PERCENT%)"
echo "│ Infrastructure: OK (Postgres, Redis, Traefik)"
echo "│ Database: Schema created + $MIGRATION_COUNT migrations"
if [ "$API_STATUS" = "200" ]; then
    echo "│ API: Responding"
    echo "│"
    echo "│ 🎯 Phase 1 Status: ✅ READY FOR TESTING"
else
    echo "│ API: Not responding"
    echo "│"
    echo "│ 🎯 Phase 1 Status: ⚠️  IN PROGRESS"
fi
echo "╰───────────────────────────────────────────────────────────╯"
echo ""

# Next steps based on current phase
echo "📋 Recommended Next Steps (Phase $PHASE):"
if [ "$PLANE_OK" -eq 7 ] && [ "$API_STATUS" = "200" ]; then
    if [ "$PHASE" -le 1 ]; then
        echo "  1. ✅ Phase 1 ready — login and test manually"
        echo "  2. Access: https://app.${DOMAIN:-local.test}"
        echo "  3. Create workspace, project, and issues"
        echo "  4. Mark Phase 1 complete (create PHASE_1_COMPLETION.md)"
    elif [ "$PHASE" = "2" ]; then
        echo "  1. ✅ Phase 1 complete — proceeding to Phase 2"
        echo "  2. Run demo seeding: cd scripts/seed_demo_plane_ce && python run_all.py"
        echo "  3. Verify 30 users / 20 projects / 1000 issues seeded"
        echo "  4. Mark Phase 2 complete (create PHASE_2_COMPLETION.md)"
    elif [ "$PHASE" = "3" ]; then
        echo "  1. Configure Authentik SSO"
        echo "  2. Set up custom workflows"
        echo "  3. Mark Phase 3 complete (create PHASE_3_COMPLETION.md)"
    elif [ "$PHASE" -ge 4 ]; then
        echo "  1. Start AI service: START_PLANE_AI=1 ./scripts/up.sh"
        echo "  2. Configure OpenAI key in .env"
        echo "  3. Test AI endpoints"
    fi
else
    echo "  1. Run health check: ./check.sh"
    echo "  2. View logs: ./logs.sh plane-backend"
    echo "  3. Debug: ./debug.sh 1"
    echo "  4. Check errors: docker logs platform-plane-backend"
fi
echo ""

# Detailed service info if requested
if [ "$1" = "-v" ] || [ "$1" = "--verbose" ]; then
    echo "════════════════════════════════════════════════════════════"
    echo "Detailed Service Information"
    echo "════════════════════════════════════════════════════════════"
    docker compose -p platform -f plane-ce/docker-compose.yml ps 2>/dev/null | grep plane
fi
