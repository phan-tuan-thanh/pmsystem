#!/bin/bash

# Pre-fix diagnostic script
# Run this BEFORE attempting any fix to get a full picture of the system state.
# Usage: ./scripts/diagnose.sh [--json]

PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

if [ -f .env ]; then
    set -a; source .env; set +a
fi

DOMAIN="${DOMAIN:-local.test}"
PROJECT="${COMPOSE_PROJECT_NAME:-platform}"
JSON_MODE=false
[ "$1" = "--json" ] && JSON_MODE=true

# ── Colour helpers ────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; RESET='\033[0m'
ok()   { echo -e "${GREEN}✅ $*${RESET}"; }
fail() { echo -e "${RED}❌ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠️  $*${RESET}"; }
info() { echo -e "${CYAN}   $*${RESET}"; }
hdr()  { echo -e "\n${BOLD}━━━ $* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"; }

ISSUES=()
add_issue() { ISSUES+=("$1"); }

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
REPORT_FILE="$PLATFORM_ROOT/logs/diagnose_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "$PLATFORM_ROOT/logs"

# Tee output to log file
exec > >(tee -a "$REPORT_FILE") 2>&1

echo -e "${BOLD}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║          Plane CE — Pre-Fix Diagnostic Report             ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo "Project : $PROJECT"
echo "Domain  : $DOMAIN"
echo "Time    : $TIMESTAMP"
echo "Report  : $REPORT_FILE"

# ════════════════════════════════════════════════════════════════
hdr "1. CONTAINER STATUS"
# ════════════════════════════════════════════════════════════════

EXPECTED_CONTAINERS=(
    "platform-postgres"
    "platform-redis"
    "platform-traefik"
    "platform-authentik-server"
    "platform-authentik-worker"
    "platform-plane-rabbitmq"
    "platform-plane-migration"
    "platform-plane-backend"
    "platform-plane-worker"
    "platform-plane-beat"
    "platform-plane-frontend"
    "platform-plane-space"
    "platform-plane-admin"
    "platform-plane-live"
)

for container in "${EXPECTED_CONTAINERS[@]}"; do
    STATUS=$(docker inspect -f '{{.State.Status}}' "$container" 2>/dev/null)
    HEALTH=$(docker inspect -f '{{.State.Health.Status}}' "$container" 2>/dev/null)
    RESTARTS=$(docker inspect -f '{{.RestartCount}}' "$container" 2>/dev/null)

    if [ -z "$STATUS" ]; then
        fail "$container: NOT FOUND"
        add_issue "Container $container does not exist"
        continue
    fi

    HEALTH_STR=""
    [ -n "$HEALTH" ] && [ "$HEALTH" != "<nil>" ] && HEALTH_STR=" | health: $HEALTH"

    if [ "$STATUS" = "running" ]; then
        if [ "$HEALTH" = "unhealthy" ]; then
            warn "$container: running${HEALTH_STR} | restarts: $RESTARTS"
            add_issue "$container is running but UNHEALTHY"
        elif [ "$RESTARTS" -gt 2 ] 2>/dev/null; then
            warn "$container: running${HEALTH_STR} | restarts: $RESTARTS (high restart count)"
            add_issue "$container has restarted $RESTARTS times"
        else
            ok "$container: running${HEALTH_STR}"
        fi
    elif [ "$STATUS" = "exited" ]; then
        EXIT_CODE=$(docker inspect -f '{{.State.ExitCode}}' "$container" 2>/dev/null)
        if [ "$container" = "platform-plane-migration" ] && [ "$EXIT_CODE" = "0" ]; then
            ok "$container: exited cleanly (migration done)"
        else
            fail "$container: exited (code: $EXIT_CODE)"
            add_issue "$container exited with code $EXIT_CODE"
        fi
    else
        fail "$container: $STATUS"
        add_issue "$container is in state: $STATUS"
    fi
done

# ════════════════════════════════════════════════════════════════
hdr "2. TRAEFIK LABEL AUDIT (certresolver check)"
# ════════════════════════════════════════════════════════════════
# Detect if running containers still have old letsencrypt labels

CONTAINERS_WITH_LABELS=(
    "platform-plane-backend"
    "platform-plane-frontend"
    "platform-plane-space"
    "platform-plane-admin"
    "platform-plane-live"
    "platform-authentik-server"
    "platform-traefik"
)

for container in "${CONTAINERS_WITH_LABELS[@]}"; do
    OLD_LABEL=$(docker inspect "$container" 2>/dev/null \
        | python3 -c "import sys,json; d=json.load(sys.stdin); \
          labels=d[0].get('Config',{}).get('Labels',{}) if d else {}; \
          print(next((v for k,v in labels.items() if 'certresolver' in k),''))" 2>/dev/null)

    TLS_LABEL=$(docker inspect "$container" 2>/dev/null \
        | python3 -c "import sys,json; d=json.load(sys.stdin); \
          labels=d[0].get('Config',{}).get('Labels',{}) if d else {}; \
          tls=[k+'='+v for k,v in labels.items() if '.tls' in k]; print('\n'.join(tls))" 2>/dev/null)

    if [ -n "$OLD_LABEL" ]; then
        fail "$container: has OLD certresolver label → '$OLD_LABEL'"
        info "Container needs to be recreated to apply tls=true fix"
        add_issue "$container running with old certresolver label (needs recreate)"
    else
        ok "$container: no certresolver (correct)"
        [ -n "$TLS_LABEL" ] && info "TLS labels: $TLS_LABEL"
    fi
done

# ════════════════════════════════════════════════════════════════
hdr "3. TRAEFIK ROUTER STATUS"
# ════════════════════════════════════════════════════════════════

TRAEFIK_API="http://localhost:8080/api"

if curl -s "$TRAEFIK_API/rawdata" >/dev/null 2>&1; then
    ROUTERS=$(curl -s "$TRAEFIK_API/rawdata" 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    routers = data.get('routers', {})
    for name, r in sorted(routers.items()):
        status = r.get('status', '?')
        rule   = r.get('rule', '')
        tls    = 'TLS' if r.get('tls') else 'plain'
        print(f'  {status:<8} [{tls}] {name}: {rule}')
except Exception as e:
    print(f'  parse error: {e}')
" 2>/dev/null)

    if [ -n "$ROUTERS" ]; then
        echo "$ROUTERS" | while IFS= read -r line; do
            if echo "$line" | grep -q "enabled"; then
                ok "$line"
            elif echo "$line" | grep -q "disabled\|error"; then
                fail "$line"
                add_issue "Traefik router disabled/error: $line"
            else
                warn "$line"
            fi
        done
    else
        warn "No routers found in Traefik API"
        add_issue "Traefik has no active routers"
    fi

    # Check specifically for plane routes
    PLANE_ROUTES=$(curl -s "$TRAEFIK_API/rawdata" 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for name in data.get('routers', {}):
    if 'plane' in name.lower():
        print(name)
" 2>/dev/null)

    if [ -z "$PLANE_ROUTES" ]; then
        fail "No plane-* routers found in Traefik"
        add_issue "Traefik has no plane routes — containers may need recreate"
    else
        ok "Plane routes detected: $(echo "$PLANE_ROUTES" | tr '\n' ' ')"
    fi
else
    warn "Traefik API not reachable at $TRAEFIK_API"
    info "Check: docker logs platform-traefik --tail 20"
fi

# ════════════════════════════════════════════════════════════════
hdr "4. NETWORK CONNECTIVITY (container → container)"
# ════════════════════════════════════════════════════════════════

check_internal() {
    local from=$1 to=$2 url=$3 label=$4
    RESULT=$(docker exec "$from" wget -qO- --timeout=5 "$url" 2>/dev/null \
             || docker exec "$from" python3 -c \
                "import urllib.request; print(urllib.request.urlopen('$url',timeout=5).read().decode()[:80])" 2>/dev/null \
             || echo "__FAIL__")
    if [ "$RESULT" = "__FAIL__" ] || [ -z "$RESULT" ]; then
        fail "$label ($from → $url)"
        add_issue "Internal connectivity failed: $from cannot reach $url"
    else
        ok "$label"
        info "Response: ${RESULT:0:80}"
    fi
}

# Backend reachable from within proxy network
if docker ps --format "{{.Names}}" | grep -q "platform-plane-backend"; then
    check_internal "platform-traefik" \
        "platform-plane-backend" \
        "http://platform-plane-backend:8000/" \
        "Traefik → plane-backend"
fi

# Postgres reachable
if docker ps --format "{{.Names}}" | grep -q "platform-postgres"; then
    if docker exec platform-postgres pg_isready -U postgres >/dev/null 2>&1; then
        ok "PostgreSQL: accepting connections"
        DB_COUNT=$(docker exec platform-postgres psql -U postgres -tc \
            "SELECT count(*) FROM pg_database WHERE datname IN ('plane_ce','authentik','plane_ai');" \
            2>/dev/null | tr -d ' ')
        info "Required DBs present: $DB_COUNT/3 (plane_ce, authentik, plane_ai)"
        [ "${DB_COUNT:-0}" -lt 3 ] && add_issue "Some required databases are missing"
    else
        fail "PostgreSQL: NOT ready"
        add_issue "PostgreSQL not accepting connections"
    fi
fi

# Redis reachable
if docker ps --format "{{.Names}}" | grep -q "platform-redis"; then
    if docker exec platform-redis redis-cli ping 2>/dev/null | grep -q PONG; then
        ok "Redis: PONG"
    else
        fail "Redis: no response"
        add_issue "Redis not responding"
    fi
fi

# RabbitMQ
if docker ps --format "{{.Names}}" | grep -q "platform-plane-rabbitmq"; then
    if docker exec platform-plane-rabbitmq rabbitmq-diagnostics ping >/dev/null 2>&1; then
        ok "RabbitMQ: healthy"
    else
        fail "RabbitMQ: not ready"
        add_issue "RabbitMQ not ready"
    fi
fi

# ════════════════════════════════════════════════════════════════
hdr "5. HTTPS ENDPOINT CHECK"
# ════════════════════════════════════════════════════════════════

check_endpoint() {
    local url=$1 name=$2
    local code
    code=$(curl -k -s -o /dev/null -w "%{http_code}" --connect-timeout 5 --max-time 10 "$url" 2>/dev/null)
    if echo "$code" | grep -qE "^(200|301|302|308)$"; then
        ok "$name → HTTP $code"
    elif [ "$code" = "401" ] || [ "$code" = "403" ]; then
        ok "$name → HTTP $code (auth required — routing works)"
    elif [ "$code" = "502" ]; then
        warn "$name → HTTP 502 (backend still starting)"
        add_issue "$name returned 502 — backend may still be booting"
    elif [ "$code" = "404" ]; then
        fail "$name → HTTP 404 (no Traefik router matched)"
        add_issue "$name 404 — Traefik router not active for this host"
    elif [ "$code" = "000" ]; then
        fail "$name → connection refused / DNS fail"
        add_issue "$name unreachable — check /etc/hosts and Traefik"
    else
        fail "$name → HTTP $code"
        add_issue "$name unexpected status: $code"
    fi
}

check_endpoint "https://traefik.${DOMAIN}/dashboard/" "Traefik Dashboard"
check_endpoint "https://app.${DOMAIN}/api/instances/"  "Plane CE API"
check_endpoint "https://app.${DOMAIN}/"               "Plane CE Frontend"
check_endpoint "https://auth.${DOMAIN}/"              "Authentik"
check_endpoint "https://space.${DOMAIN}/spaces/"      "Plane Space"
check_endpoint "https://admin.${DOMAIN}/god-mode/"    "Plane Admin"

# ════════════════════════════════════════════════════════════════
hdr "6. DATABASE SCHEMA CHECK"
# ════════════════════════════════════════════════════════════════

if docker exec platform-postgres pg_isready -U postgres >/dev/null 2>&1; then
    MIGRATION_COUNT=$(docker exec platform-postgres psql -U plane_ce -d plane_ce -tc \
        "SELECT count(*) FROM django_migrations;" 2>/dev/null | tr -d ' \n')
    if [ -n "$MIGRATION_COUNT" ] && [ "$MIGRATION_COUNT" -gt 0 ] 2>/dev/null; then
        ok "Django migrations applied: $MIGRATION_COUNT"
    else
        fail "No Django migrations found in plane_ce DB"
        add_issue "Database schema not initialized — migration may have failed"
    fi

    # Check plane_ce user owns schema
    SCHEMA_OWNER=$(docker exec platform-postgres psql -U postgres -d plane_ce -tc \
        "SELECT schema_owner FROM information_schema.schemata WHERE schema_name='public';" \
        2>/dev/null | tr -d ' \n')
    if [ "$SCHEMA_OWNER" = "plane_ce" ]; then
        ok "plane_ce owns public schema"
    else
        warn "Schema owner is '$SCHEMA_OWNER' (expected 'plane_ce')"
        add_issue "plane_ce schema ownership incorrect — may cause permission errors"
    fi
fi

# ════════════════════════════════════════════════════════════════
hdr "7. TLS CERTIFICATE CHECK"
# ════════════════════════════════════════════════════════════════

if [ -f "$PLATFORM_ROOT/traefik/certs/local.crt" ]; then
    CERT_SUBJECT=$(openssl x509 -in "$PLATFORM_ROOT/traefik/certs/local.crt" -noout -subject 2>/dev/null)
    CERT_EXPIRY=$(openssl x509 -in "$PLATFORM_ROOT/traefik/certs/local.crt" -noout -enddate 2>/dev/null)
    CERT_SAN=$(openssl x509 -in "$PLATFORM_ROOT/traefik/certs/local.crt" -noout -text 2>/dev/null \
        | grep -A1 "Subject Alternative Name" | tail -1 | tr -d ' ')
    ok "Local cert found"
    info "$CERT_SUBJECT"
    info "$CERT_EXPIRY"
    info "SAN: $CERT_SAN"

    # Verify cert covers the domain
    if echo "$CERT_SUBJECT $CERT_SAN" | grep -q "$DOMAIN\|local.test"; then
        ok "Cert covers domain: $DOMAIN"
    else
        fail "Cert does NOT cover domain: $DOMAIN"
        add_issue "TLS cert subject/SAN does not match domain $DOMAIN"
    fi
else
    fail "traefik/certs/local.crt not found"
    add_issue "TLS certificate file missing"
fi

# ════════════════════════════════════════════════════════════════
hdr "8. /etc/hosts CHECK"
# ════════════════════════════════════════════════════════════════

REQUIRED_HOSTS=("traefik.$DOMAIN" "auth.$DOMAIN" "app.$DOMAIN" "space.$DOMAIN" "admin.$DOMAIN")
for host in "${REQUIRED_HOSTS[@]}"; do
    if grep -q "127.0.0.1.*$host" /etc/hosts; then
        ok "$host → 127.0.0.1"
    else
        fail "$host missing from /etc/hosts"
        add_issue "$host not in /etc/hosts"
    fi
done

# ════════════════════════════════════════════════════════════════
hdr "SUMMARY"
# ════════════════════════════════════════════════════════════════

TOTAL_ISSUES=${#ISSUES[@]}
if [ "$TOTAL_ISSUES" -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}✅ All checks passed — system looks healthy.${RESET}"
    echo "   Run ./scripts/check.sh for full health verification."
else
    echo -e "\n${RED}${BOLD}❌ Found $TOTAL_ISSUES issue(s) to fix:${RESET}\n"
    for i in "${!ISSUES[@]}"; do
        echo -e "  $((i+1)). ${RED}${ISSUES[$i]}${RESET}"
    done

    echo ""
    echo -e "${BOLD}Suggested fix order:${RESET}"

    # Smart fix suggestions based on what was found
    HAS_CERTRESOLVER=false
    HAS_DB_ISSUE=false
    HAS_HOSTS_ISSUE=false
    HAS_ROUTING_ISSUE=false

    for issue in "${ISSUES[@]}"; do
        echo "$issue" | grep -qi "certresolver\|recreate" && HAS_CERTRESOLVER=true
        echo "$issue" | grep -qi "database\|migration\|schema" && HAS_DB_ISSUE=true
        echo "$issue" | grep -qi "hosts\|dns" && HAS_HOSTS_ISSUE=true
        echo "$issue" | grep -qi "404\|router\|routing" && HAS_ROUTING_ISSUE=true
    done

    STEP=1
    if [ "$HAS_HOSTS_ISSUE" = true ]; then
        echo "  $STEP. Fix /etc/hosts: sudo ./scripts/setup-hosts.sh"
        STEP=$((STEP+1))
    fi
    if [ "$HAS_CERTRESOLVER" = true ] || [ "$HAS_ROUTING_ISSUE" = true ]; then
        echo "  $STEP. Recreate containers with new labels:"
        echo "       docker compose -p $PROJECT --env-file .env \\"
        echo "         -f traefik/docker-compose.yml \\"
        echo "         -f plane-ce/docker-compose.yml \\"
        echo "         -f authentik/docker-compose.yml up -d --force-recreate"
        STEP=$((STEP+1))
    fi
    if [ "$HAS_DB_ISSUE" = true ]; then
        echo "  $STEP. Re-run migration:"
        echo "       docker rm platform-plane-migration 2>/dev/null || true"
        echo "       docker compose -p $PROJECT --env-file .env \\"
        echo "         -f plane-ce/docker-compose.yml run --rm plane-migration"
        STEP=$((STEP+1))
    fi
    echo "  $STEP. Re-run this script to verify: ./scripts/diagnose.sh"
fi

echo ""
echo "Full report saved to: $REPORT_FILE"
