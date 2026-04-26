# Phase-Aware Health Checking

## 📋 Overview

The updated `check.sh` script is now **phase-aware** - it only checks services and endpoints that belong to the current deployment phase and previously completed phases.

## 🎯 How It Works

### Phase Detection

```bash
# Phase 1: Checks if PHASE_1_COMPLETION.md or DEPLOYMENT_PLAN.md exists
PHASE=1

# Phase 2+: Future phases checked when started
PHASE=2
```

### Service Groups by Phase

**Phase 1 (Core Infrastructure)** - 12 services:
```
Infrastructure:
  • platform-postgres
  • platform-redis
  • platform-traefik
  • platform-authentik-server
  • platform-authentik-worker

Plane CE Core:
  • platform-plane-backend
  • platform-plane-worker
  • platform-plane-beat
  • platform-plane-frontend
  • platform-plane-space
  • platform-plane-admin
  • platform-plane-live
```

**Phase 2+ (AI Service)** - 1 additional service:
```
  • platform-plane-ai
```

### Endpoint Checks by Phase

**Phase 1:**
- ✅ Traefik Dashboard (`https://traefik.local.test/dashboard/`)
- ✅ Authentik Login (`https://auth.local.test`)
- ✅ Plane CE Frontend (`https://app.local.test`)
- ✅ Plane CE API (`https://app.local.test/api/health/`)

**Phase 2+:**
- ✅ Plane AI Service (`https://ai.local.test/health/`)

### Infrastructure Checks by Phase

**Phase 1:**
- ✅ PostgreSQL connectivity & user count
- ✅ Redis connectivity & key count
- ✅ Database migrations
- ✅ plane_ce user in database
- ✅ Admin user in database

## 📊 Example Output

### Phase 1 Output

```bash
$ ./check.sh

🧹 Cleared old debug logs from logs/debug
🚀 Plane CE Health Check - Phase 1
==========================================
Project: platform
Checking: 12 services for Phase 1    ← Shows Phase 1 has 12 services
Time: Sun Apr 26 00:22:59 +07 2026
==========================================

✅ platform-postgres: running
✅ platform-redis: running
✅ platform-traefik: running
✅ platform-authentik-server: running
✅ platform-authentik-worker: running
✅ platform-plane-backend: running
[... other Phase 1 services ...]

📋 Infrastructure Connectivity Check (Phase 1)  ← Phase-specific checks
---
✅ PostgreSQL: Ready
✅ Redis: Ready

Checking Web Endpoints (Phase 1)...  ← Only Phase 1 endpoints
---
✅ Traefik Dashboard: Reachable
✅ Authentik Login: Reachable
✅ Plane CE Frontend: Reachable
✅ Plane CE API: Reachable

🔍 Phase 1 Specific Checks  ← Phase-specific validations
---
✅ Database Migrations: 76 executed
✅ plane_ce Database User: Created
✅ Admin User (admin@plane.local): Created
```

### Phase 2+ Output (Future)

```bash
$ ./check.sh

🧹 Cleared old debug logs from logs/debug
🚀 Plane CE Health Check - Phase 2
==========================================
Project: platform
Checking: 13 services for Phase 2    ← Includes AI Service
Time: Sun Apr 26 00:22:59 +07 2026
==========================================

[... Phase 1 services ...]
✅ platform-plane-ai: running  ← Phase 2 addition

📋 Infrastructure Connectivity Check (Phase 2)
---
✅ PostgreSQL: Ready
✅ Redis: Ready

Checking Web Endpoints (Phase 2)...
---
✅ Traefik Dashboard: Reachable
✅ Authentik Login: Reachable
✅ Plane CE Frontend: Reachable
✅ Plane CE API: Reachable
✅ Plane AI Service: Reachable  ← Phase 2 endpoint

🔍 Phase 2 Specific Checks
---
✅ Database Migrations: 76 executed
✅ Demo Users: 30 created
✅ Demo Projects: 20 created
✅ Demo Issues: 1000+ created
```

## 🔄 Implementation Details

### Phase Detection Code

```bash
detect_phase() {
    if [ -f "../PHASE_1_COMPLETION.md" ] && grep -q "Status.*COMPLETE" ../PHASE_1_COMPLETION.md; then
        echo "1"
    elif [ -f "../DEPLOYMENT_PLAN.md" ]; then
        echo "1"
    else
        echo "0"  # No phase detected yet
    fi
}
```

### Container Selection Code

```bash
get_phase_containers() {
    local phase=$1
    local containers=()

    # Phase 1: Core services (always)
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

    # Phase 2+: AI Service (added when Phase 2 starts)
    if [ "$phase" -ge 2 ]; then
        containers+=("platform-plane-ai")
    fi

    printf '%s\n' "${containers[@]}"
}
```

## 📈 Benefits

| Aspect | Before | After |
|--------|--------|-------|
| **Irrelevant Failures** | ❌ "AI not found" error in Phase 1 | ✅ Only Phase 1 services checked |
| **Clean Output** | ❌ Cluttered with unrelated services | ✅ Only relevant services shown |
| **False Positives** | ❌ Phase 1 fails because Phase 2 missing | ✅ Phase 1 checks only Phase 1 |
| **Scalability** | ❌ Add Phase → Update check manually | ✅ Auto-adjusts based on phase |
| **Documentation** | ❌ Unclear what should be checked | ✅ Clearly shows "Checking N services" |

## 🔗 Integration with Deployment

### Workflow

```
1. Start Phase 1 deployment
   ↓
2. Run ./check.sh
   → Detects Phase 1
   → Checks 12 services
   → No AI service errors
   ↓
3. Complete Phase 1 ✅
   ↓
4. Start Phase 2 (add AI service, data seeding)
   ↓
5. Run ./check.sh
   → Detects Phase 2
   → Checks 13 services (includes AI)
   → New endpoint checks
   ↓
6. Continue to Phase 3+
```

## 📝 Future Phases

### Phase 2 (Data Seeding)
When started, check.sh will also verify:
- Demo users count (30+)
- Demo projects count (20+)
- Demo sprints count (85+)
- Demo issues count (1000+)

### Phase 3 (Extensions)
Will add checks for:
- Authentik SSO configuration
- Custom workflow setup
- Integration status

### Phase 4 (AI Enhancements)
Will add checks for:
- OpenAI API connectivity
- AI endpoint response times
- Usage metrics

### Phase 5 (Production Hardening)
Will add checks for:
- Backup status
- Monitoring alerts
- Performance metrics

## 🚀 Adding New Phases

To add a new phase to check.sh:

1. **Update phase detection:**
```bash
detect_phase() {
    # ... existing code ...
    if [ -f "../PHASE_3_STARTED.md" ]; then
        echo "3"
    fi
}
```

2. **Add containers for new phase:**
```bash
get_phase_containers() {
    # ... Phase 1 & 2 code ...
    
    # Phase 3: Add new services
    if [ "$phase" -ge 3 ]; then
        containers+=("platform-new-service")
    fi
}
```

3. **Add phase-specific endpoints:**
```bash
# Phase 3+: Check new endpoints
if [ "$PHASE" -ge 3 ]; then
    check_endpoint "https://example.$DOMAIN" "Example Service"
fi
```

4. **Add phase-specific checks:**
```bash
if [ "$PHASE" = "3" ]; then
    # Phase 3 specific validations
    echo "🔍 Phase 3 Specific Checks"
fi
```

## 💡 Key Benefits

1. **No False Positives** - Services not yet deployed don't fail the check
2. **Clear Progress** - See exactly what phase you're in
3. **Scalable Design** - Easy to add new phases
4. **Self-Documenting** - Output shows what's being checked
5. **Safe Deployments** - Know which services are expected to exist

## 🔍 Checking Your Phase

```bash
# Quick way to see current phase
./check.sh | head -10

# Output will show:
# 🚀 Plane CE Health Check - Phase 1
# Checking: 12 services for Phase 1
```

---

**Status**: ✅ Phase-aware checking implemented  
**Current Phase**: 1 (Core Infrastructure)  
**Future**: Auto-scales as new phases start
