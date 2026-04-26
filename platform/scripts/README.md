# Plane CE Deployment Scripts

Phase-aware scripts for managing Plane CE deployment across 5 phases.

## 📋 Core Scripts (Phase 1+)

### `./up.sh`
Start all Plane CE services
```bash
./up.sh
```
- Starts PostgreSQL, Redis, Traefik, Authentik
- Starts all 8 Plane CE services
- Waits for health checks
- Shows startup status

### `./down.sh`
Stop all Plane CE services
```bash
./down.sh
```
- Stops all running containers
- Preserves volumes and data
- Safe shutdown

### `./check.sh` (Updated)
Health check for all services
```bash
./check.sh
```
**Features:**
- ✅ Container status check
- ✅ Infrastructure connectivity (Postgres, Redis)
- ✅ Web endpoint availability
- ✅ Phase-specific checks (migrations, users, projects)
- ✅ Next steps based on phase
- ✅ Detailed error reporting

### `./logs.sh`
View logs for any service
```bash
./logs.sh <service_name>
./logs.sh plane-backend      # View backend logs
./logs.sh postgres           # View database logs
./logs.sh                    # List all services
```

### `./setup-hosts.sh`
Configure /etc/hosts for local domains
```bash
./setup-hosts.sh
```
Configures:
- `traefik.local.test`
- `auth.local.test`
- `app.local.test`
- `space.local.test`
- `admin.local.test`
- `ai.local.test`

---

## 🆕 Phase-Aware Scripts

### `./phase-progress.sh` (NEW)
Show detailed phase progress and metrics
```bash
./phase-progress.sh
./phase-progress.sh -v        # Verbose (show all services)
```
**Shows:**
- Current phase
- Services running count & status
- Database metrics (migrations, users, projects)
- API health status
- Completion percentage
- Recommended next steps

**Output Example:**
```
Phase 1: Core Docker Infrastructure
✅ PostgreSQL
✅ Redis
✅ Traefik
✅ plane-backend (running)
✅ plane-frontend (running)
✅ plane-worker (running)
✅ plane-beat (running)
✅ plane-live (running)
✅ plane-admin (running)
✅ plane-space (running)

Database: 76 migrations, 1 users, 0 projects
API: Responding
Status: ✅ READY FOR TESTING (100%)
```

### `./debug.sh` (NEW)
Troubleshoot specific phase and service
```bash
./debug.sh 1                  # Debug phase 1 (all services)
./debug.sh 1 backend          # Debug phase 1 backend
./debug.sh 1 postgres         # Debug phase 1 postgres
./debug.sh 1 redis            # Debug phase 1 redis
```
**Features:**
- Container status details
- Recent logs (filtered)
- Environment variables
- Database connectivity test
- Port availability check
- Quick troubleshooting steps

---

## 🔍 Usage Guide by Phase

### Phase 1: Core Docker Setup
**Goal**: Get all services running

```bash
# 1. Start services
./up.sh

# 2. Check health
./check.sh

# 3. If issues, debug
./debug.sh 1
./debug.sh 1 backend          # Debug specific service

# 4. View logs
./logs.sh plane-backend

# 5. Check progress
./phase-progress.sh           # Shows Phase 1 completion %
```

**Success Criteria:**
- `./check.sh` shows all ✅
- `./phase-progress.sh` shows 100%
- Can access https://app.local.test
- Can login with admin@plane.local

### Phase 2: Demo Data Seeding
**Goal**: Populate with test data

```bash
# 1. Verify Phase 1 complete
./check.sh

# 2. Seed demo data
cd seed_demo_plane_ce
python run_all.py

# 3. Verify seeding
./phase-progress.sh           # Should show 30 users, 20 projects, etc
```

### Phase 3+: Extensions & Customizations
```bash
# Keep monitoring
./check.sh                    # Verify system stability
./phase-progress.sh           # Track progress
./debug.sh <phase> <service>  # Troubleshoot issues
```

---

## 📊 Environment Variables

Scripts load from `.env`:
```bash
DOMAIN=local.test
PLANE_POSTGRES_DB=plane_ce
PLANE_POSTGRES_USER=plane_ce
PLANE_POSTGRES_PASSWORD=PlanePass123!
COMPOSE_PROJECT_NAME=platform
```

---

## 🔧 Common Commands

### Health Check
```bash
./check.sh
```

### View All Containers
```bash
docker ps
```

### View Specific Service Logs
```bash
./logs.sh plane-backend
docker logs -f platform-plane-backend
```

### Restart Services
```bash
docker compose -p platform restart
./down.sh && ./up.sh
```

### Check Database
```bash
docker exec platform-postgres psql -U plane_ce -d plane_ce
```

### Check Redis
```bash
docker exec platform-redis redis-cli
```

### Test API
```bash
curl -k https://app.local.test/api/health/
```

---

## 📈 Monitoring Progress

Throughout deployment:

1. **Phase 1 (Weeks 1-2)**
   ```bash
   ./check.sh              # All services running?
   ./phase-progress.sh     # Backend + API working?
   ```

2. **Phase 2 (Week 3)**
   ```bash
   ./phase-progress.sh -v  # 30 users? 20 projects?
   ```

3. **Phase 3-5 (Weeks 4-12)**
   ```bash
   ./check.sh              # Still healthy?
   ./phase-progress.sh     # Performance metrics?
   ./debug.sh <phase> <service>  # Any issues?
   ```

---

## 🚨 Troubleshooting

### Services not starting?
```bash
./debug.sh 1
./logs.sh plane-backend
```

### API not responding?
```bash
curl -k https://app.local.test/api/health/
./debug.sh 1 backend
```

### Database connection issues?
```bash
./debug.sh 1 postgres
docker exec platform-postgres pg_isready
```

### Check everything
```bash
./check.sh
./phase-progress.sh
./debug.sh 1
```

---

## 📚 Related Documentation

- `../CLAUDE.md` - Project overview
- `../PLANE_CE_SETUP.md` - Complete setup guide
- `../OFFICIAL_SETUP_GUIDE.md` - Service details
- `../DEPLOYMENT_PLAN.md` - 5-phase plan
- `../PHASE_1_COMPLETION.md` - Phase 1 details

---

**Last Updated**: 2026-04-25  
**Status**: Phase-aware scripts ready
