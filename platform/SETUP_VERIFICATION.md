# Plane CE + AI Setup Verification Checklist

## 📋 Initialization Status

### Services Status
- [ ] ✅ PostgreSQL - Running & Healthy
- [ ] ✅ Redis - Running & Healthy  
- [ ] ✅ Traefik - Running & Healthy
- [ ] ✅ Authentik - Running & Healthy
- [ ] ⏳ Plane Backend - Starting (waiting for migration)
- [ ] ⏳ Plane Frontend - Starting
- [ ] ⏳ Plane Worker - Starting
- [ ] ⏳ Plane Beat - Starting
- [ ] ⏳ Plane Live - Starting
- [ ] ⏳ Plane Admin - Starting
- [ ] ⏳ Plane Space - Starting
- [ ] ✅ Plane AI Service - Running

### Database Migration
The database migration service (`plane-migration`) runs automatically:
```
✅ Creates schema
✅ Runs Django migrations
✅ Collects static files
✅ Exits after completion
```

### Expected Flow
1. **plane-migration** starts → runs migrations → exits
2. **plane-backend** starts (depends on migration)
3. Other services start (depend on plane-backend)

## 🔍 Verification Commands

### Check Container Status
```bash
cd platform
docker ps | grep plane
```

Expected: All plane-* containers in "Up" status

### Check Logs for Errors
```bash
# Backend logs
./scripts/logs.sh plane-backend | head -50

# Migration logs
docker logs platform-plane-migration

# Worker logs
./scripts/logs.sh plane-worker
```

### Health Check
```bash
./scripts/check.sh
```

Expected output:
```
✅ platform-postgres: running
✅ platform-redis: running
✅ platform-traefik: running
✅ platform-authentik-server: running
✅ platform-plane-backend: running
✅ platform-plane-worker: running
✅ platform-plane-beat: running
✅ platform-plane-frontend: running
✅ platform-plane-space: running
✅ platform-plane-admin: running
✅ platform-plane-live: running
✅ platform-plane-ai: running
```

## 🌐 Access Services

### Plane CE Main Application
```
URL: https://app.local.test
Username: admin@plane.local
Password: PlaneAdmin123!
```

### Plane CE Admin
```
URL: https://admin.local.test
```

### Plane CE Public Sharing
```
URL: https://space.local.test
```

### Plane AI Service
```
URL: https://ai.local.test
Health: https://ai.local.test/health/
```

### Authentik SSO
```
URL: https://auth.local.test
```

### Traefik Dashboard
```
URL: https://traefik.local.test/dashboard/
```

## 🧪 Test Plane CE

### 1. Login to Plane CE
```bash
# In browser:
https://app.local.test
# Login with: admin@plane.local / PlaneAdmin123!
```

### 2. Create Workspace
- Click "Create Workspace"
- Give it a name (e.g., "Demo")
- Set slug (e.g., "demo")
- Create workspace

### 3. Create Project
- In workspace, click "New Project"
- Name: "Test Project"
- Identifier: "TEST"
- Create project

### 4. Create Issue
- Open project
- Click "Add Issue"
- Title: "Test Issue"
- Create issue

### 5. Test AI Features (if enabled)
```bash
# Check AI health
curl -k https://ai.local.test/health/

# Get agile metrics
curl -k https://ai.local.test/api/v1/agile-metrics/ws/proj
```

## 🔧 Troubleshooting

### Containers Restarting
Check logs:
```bash
docker logs platform-plane-backend 2>&1 | tail -100
```

Common issues:
- Database not ready → wait longer
- Wrong credentials → check .env
- Permission issues → check volumes

### Migration Failed
```bash
docker logs platform-plane-migration

# If needs to re-run:
docker compose -p platform -f plane-ce/docker-compose.yml rm plane-migration
docker compose -p platform -f plane-ce/docker-compose.yml up -d plane-migration
```

### API Not Responding
```bash
# Check backend health
curl -k https://app.local.test/api/health/

# Check if port is open
docker port platform-plane-backend

# Check logs for errors
./scripts/logs.sh plane-backend | tail -100
```

### Frontend Blank Page
- Check browser console for errors
- Verify NEXT_PUBLIC_API_BASE_URL in .env
- Check if backend is responding

## 📊 Docker Compose Structure

The new docker-compose.yml includes:

### Services
```
plane-migration      (runs once, creates schema)
├─ plane-backend    (Django API)
│  ├─ plane-worker  (Celery worker)
│  ├─ plane-beat    (Celery scheduler)
│  └─ plane-live    (WebSocket server)
├─ plane-frontend   (Next.js UI)
├─ plane-admin      (Admin dashboard)
└─ plane-space      (Public sharing)
```

### Key Features
- ✅ Automatic database migrations
- ✅ Proper service dependencies
- ✅ Traefik integration
- ✅ Health checks for all services
- ✅ Shared proxy network
- ✅ Volume mounts for logs & data

## 📝 Configuration

### Environment Variables (.env)
```bash
DOMAIN=local.test
PLANE_POSTGRES_DB=plane_ce
PLANE_POSTGRES_USER=plane_ce
PLANE_POSTGRES_PASSWORD=PlanePass123!
PLANE_SECRET_KEY=<generated-key>
PLANE_ADMIN_EMAIL=admin@plane.local
PLANE_ADMIN_PASSWORD=PlaneAdmin123!
```

### Volumes
```
./logs/    - Service logs
./data/    - Application data
```

## 🚀 Next Steps

### Immediate
1. Wait for migration to complete
2. Verify all services are healthy
3. Test login to Plane CE
4. Create test project

### Configuration
1. Set custom DOMAIN in .env if needed
2. Configure email (SMTP_*)
3. Configure S3/MinIO if needed
4. Setup Authentik integration

### Data
1. Seed demo data: `python scripts/seed_demo_plane_ce/run_all.py`
2. Create sample projects
3. Test AI features

## 📚 Documentation

- [Plane CE Docs](https://docs.plane.so)
- [Self-hosting Guide](https://docs.plane.so/self-hosting)
- [API Documentation](https://docs.plane.so/api)
- [GitHub Repository](https://github.com/makeplane/plane)

## 🎯 Success Criteria

✅ System is working when:
1. All containers show "Up" status
2. `./scripts/check.sh` shows all green
3. Can login to https://app.local.test
4. Can create workspace and project
5. Can create and view issues
6. Plane AI service responds at https://ai.local.test/health/

## 📞 Support

If issues occur:

1. **Check logs**: `./scripts/logs.sh <service>`
2. **Check health**: `./scripts/check.sh`
3. **Check containers**: `docker ps -a`
4. **Check networks**: `docker network ls`
5. **Check volumes**: `docker volume ls`

---

**Status**: Setup in progress  
**Last Updated**: 2026-04-25  
**Branch**: plane_ce
