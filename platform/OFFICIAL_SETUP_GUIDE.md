# Plane CE + AI Official Setup Guide

Complete guide for Plane CE official docker-compose integration with existing infrastructure.

## 🎯 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                      Infrastructure Layer                    │
├──────────────────┬──────────────────┬──────────────────────┤
│   PostgreSQL     │      Redis       │  Traefik/Authentik  │
│   (Shared DB)    │   (Shared Cache) │   (Reverse Proxy)   │
└──────┬───────────┴────────┬─────────┴──────────┬────────────┘
       │                    │                    │
       └────────────────┬───┴───┬────────────────┘
                        │       │
┌───────────────────────┴───────┴───────────────────────────┐
│                    Plane CE Services                       │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────┐                                        │
│  │ plane-       │ (Database migrations on startup)       │
│  │ migration    │                                        │
│  └──────┬───────┘                                        │
│         │ creates schema                                 │
│  ┌──────▼──────────────────────────────────────┐        │
│  │         Plane Backend (Django)              │        │
│  │    PORT 8000 - Core API Server             │        │
│  └──────┬──────────────────────────────────────┘        │
│         │                                                │
│    ┌────┴────────┬──────────────┬──────────────┐        │
│    │             │              │              │        │
│  ┌─▼───────┐ ┌──▼──────┐ ┌────▼──────┐ ┌────▼──────┐  │
│  │ Worker  │ │  Beat   │ │   Live    │ │ Frontend  │  │
│  │ Celery  │ │Scheduler│ │ WebSocket │ │ Next.js   │  │
│  └────────┘ └─────────┘ └───────────┘ └────────────┘  │
│                                                           │
│  ┌──────────────────┐  ┌──────────────────────┐         │
│  │ plane-admin      │  │ plane-space          │         │
│  │ Admin Dashboard  │  │ Public Sharing       │         │
│  └──────────────────┘  └──────────────────────┘         │
└───────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────┐
│            Plane AI Service (Independent)                 │
│  FastAPI Application - PORT 8001                          │
│  5 AI Endpoints for Agile Management                      │
└───────────────────────────────────────────────────────────┘
```

## 🚀 Quick Start

### Step 1: Verify Infrastructure

```bash
cd platform
./scripts/check.sh
```

Expected:
```
✅ Postgres: Ready
✅ Redis: Ready
✅ Traefik: Reachable
✅ Authentik: Reachable
```

### Step 2: Start Plane CE

```bash
docker compose -p platform --env-file .env -f plane-ce/docker-compose.yml up -d
```

Services will start in order:
1. `plane-migration` (creates database schema)
2. `plane-backend` (waits for migration)
3. Other services (wait for backend)

### Step 3: Wait for Startup

```bash
# Monitor backend logs
./scripts/logs.sh plane-backend

# Or check all services
docker ps | grep plane
```

Expected timeframe: 2-3 minutes for first startup

### Step 4: Access Plane CE

```
URL: https://app.local.test
Email: admin@plane.local
Password: PlaneAdmin123!
```

## 📦 Service Details

### plane-migration
- **Purpose**: One-time database setup
- **Runs**: On first startup
- **Actions**:
  - Creates database schema
  - Runs Django migrations
  - Collects static files
  - Exits (restart: "no")

### plane-backend
- **Image**: `makeplane/plane-backend:latest`
- **Port**: 8000
- **Purpose**: Django REST API server
- **Key Functions**:
  - Processes API requests
  - Manages database operations
  - Handles file uploads (S3/MinIO)
- **Dependencies**: PostgreSQL, Redis
- **Health Check**: `curl http://localhost:8000/api/health/`

### plane-worker
- **Image**: `makeplane/plane-worker:latest`
- **Purpose**: Celery background task worker
- **Key Functions**:
  - Async tasks (emails, exports, etc.)
  - Real-time notifications
  - File processing
- **Dependencies**: plane-backend, Redis
- **Health Check**: `celery -A plane inspect ping`

### plane-beat
- **Image**: `makeplane/plane-worker:latest`
- **Purpose**: Celery Beat scheduler
- **Key Functions**:
  - Scheduled tasks
  - Periodic jobs
  - Cron-like operations
- **Dependencies**: plane-backend

### plane-frontend
- **Image**: `makeplane/plane-frontend:latest`
- **Port**: 3000
- **Purpose**: Next.js web UI
- **Key Features**:
  - Responsive interface
  - Real-time collaboration
  - Project management UI
- **Dependencies**: plane-backend
- **Health Check**: `curl http://localhost:3000/`

### plane-live
- **Image**: `makeplane/plane-live:latest`
- **Port**: 3003
- **Purpose**: WebSocket server for real-time features
- **Key Functions**:
  - Real-time updates
  - Live collaboration
  - Push notifications
- **Protocol**: WebSocket (ws://)

### plane-admin
- **Image**: `makeplane/plane-admin:latest`
- **Port**: 3002
- **Purpose**: Admin dashboard
- **Features**:
  - System administration
  - User management
  - Instance settings

### plane-space
- **Image**: `makeplane/plane-space:latest`
- **Port**: 3001
- **Purpose**: Public project sharing
- **Features**:
  - Public project views
  - Share links
  - Guest access

## 🔌 Integration Points

### Database Integration
```
Connection: platform-postgres:5432
Database: plane_ce
User: plane_ce
Shared: ✅ (Also used by Authentik)
```

### Redis Integration
```
Connection: platform-redis:6379
Database: 0
Shared: ✅ (Shared with other services)
```

### Traefik Integration
```
Network: proxy (external)
Routes:
  app.local.test       → plane-frontend
  admin.local.test     → plane-admin
  space.local.test     → plane-space
  app.local.test/api   → plane-backend
  app.local.test/ws    → plane-live
```

### Authentik Integration
```
Ready for: OAuth2 integration
Path: Settings → Security → OAuth Providers
```

## 📊 Environment Configuration

### Required Variables (.env)

```bash
# Domain
DOMAIN=local.test

# Database
PLANE_POSTGRES_DB=plane_ce
PLANE_POSTGRES_USER=plane_ce
PLANE_POSTGRES_PASSWORD=PlanePass123!

# Security
PLANE_SECRET_KEY=<should-be-long-random-string>

# Admin Account
PLANE_ADMIN_EMAIL=admin@plane.local
PLANE_ADMIN_PASSWORD=PlaneAdmin123!

# File Storage
AWS_S3_BUCKET_NAME=plane-files
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_S3_ENDPOINT_URL=http://platform-minio:9000
```

### Optional Variables

```bash
# Email
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=noreply@plane.local
SMTP_PASSWORD=
SMTP_USE_TLS=true

# Logging
LOG_LEVEL=INFO
```

## 🧪 Testing

### Test Backend Health
```bash
curl -k https://app.local.test/api/health/
```

Expected response:
```json
{"status":"healthy"}
```

### Test Frontend
```bash
# Open in browser
https://app.local.test

# Login
Email: admin@plane.local
Password: PlaneAdmin123!
```

### Test WebSocket
```bash
# The frontend will automatically use WebSocket
# Check browser console for any errors
```

### Test AI Service
```bash
curl -k https://ai.local.test/health/

# Expected response
{"status":"healthy","version":"1.0.0"}
```

## 🔄 Management Commands

### View Logs
```bash
# All plane logs
./scripts/logs.sh plane-backend
./scripts/logs.sh plane-worker

# Or directly
docker logs -f platform-plane-backend
```

### Restart Services
```bash
# Single service
docker compose -p platform -f plane-ce/docker-compose.yml restart plane-backend

# All plane services
docker compose -p platform -f plane-ce/docker-compose.yml restart
```

### Stop Services
```bash
docker compose -p platform -f plane-ce/docker-compose.yml down
```

### Check Status
```bash
./scripts/check.sh
```

## 📈 Monitoring

### View Running Containers
```bash
docker ps | grep plane
```

### Check Resource Usage
```bash
docker stats platform-plane-backend platform-plane-frontend
```

### View Service Dependencies
```bash
docker network inspect proxy
```

## 🆘 Common Issues

### Services Keep Restarting

**Cause**: Migration failed or backend crashed  
**Solution**:
```bash
# Check logs
docker logs platform-plane-migration
docker logs platform-plane-backend

# If migration crashed, re-run
docker compose -p platform -f plane-ce/docker-compose.yml up -d plane-migration
```

### Can't Connect to Database

**Cause**: PostgreSQL not ready or wrong credentials  
**Solution**:
```bash
# Check PostgreSQL
./scripts/logs.sh postgres
docker exec platform-postgres pg_isready

# Verify .env
grep PLANE_POSTGRES .env
```

### API Returns 404

**Cause**: Backend not fully started  
**Solution**:
```bash
# Wait longer (usually 2-3 minutes)
sleep 60
./scripts/check.sh

# Check if backend is running
docker ps | grep plane-backend
```

### Frontend Blank/Errors

**Cause**: API not responding or wrong URL  
**Solution**:
```bash
# Check API responds
curl -k https://app.local.test/api/health/

# Check frontend logs
docker logs -f platform-plane-frontend

# Verify NEXT_PUBLIC variables
```

## 🔐 Security Notes

### For Production

1. **Change default password**: Update PLANE_ADMIN_PASSWORD in .env
2. **Generate SECRET_KEY**: Use strong random key
3. **Configure HTTPS**: Traefik handles this
4. **Setup proper email**: Configure SMTP_*
5. **Backup database**: Regular PostgreSQL backups
6. **Secure S3/MinIO**: Use strong credentials

### For Development

- Current setup uses self-signed certificates (ignore warnings)
- Access https://app.local.test (with -k flag for curl)
- Local.test domain is development-only

## 📚 Next Steps

### Immediate
1. ✅ Start Plane CE
2. ✅ Verify all services running
3. ✅ Login and test features
4. ✅ Create sample project

### Short-term
1. Seed demo data
2. Configure email
3. Setup Authentik OAuth
4. Test AI features

### Long-term  
1. Production deployment
2. Backup strategy
3. Monitoring setup
4. Custom branding

## 📞 Getting Help

- [Plane CE Docs](https://docs.plane.so)
- [GitHub Issues](https://github.com/makeplane/plane/issues)
- [Docker Logs](./scripts/logs.sh)
- [Health Check](./scripts/check.sh)

---

**Version**: Official Docker Compose Integration  
**Last Updated**: 2026-04-25  
**Status**: Ready for Testing
