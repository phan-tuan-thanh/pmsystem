# Plane CE + AI Project Documentation

This document describes the Plane CE + AI solution for replacing NocoBase with a modern, AI-enhanced Agile project management platform.

## Project Overview

**Goal**: Transition from NocoBase to Plane CE as the primary business platform, with AI enhancements for Agile workflows.

**Key Components**:
- Plane CE: Open-source project management platform
- Plane AI Service: FastAPI-based AI enhancement layer
- Shared Infrastructure: Traefik, Authentik, PostgreSQL, Redis
- Demo Data: Comprehensive seed scripts for testing

## Repository Structure

```
pmsystem/
├── platform/
│   ├── .env                    # Environment configuration
│   ├── PLANE_CE_SETUP.md       # Complete setup guide
│   ├── plane-ce/               # Plane CE Docker Compose
│   ├── plane-ai/               # AI Service (FastAPI)
│   ├── authentik/              # SSO service
│   ├── postgres/               # Database
│   ├── redis/                  # Cache
│   ├── traefik/                # Reverse proxy
│   └── scripts/
│       ├── up.sh               # Start services
│       ├── down.sh             # Stop services
│       ├── check.sh            # Health check
│       ├── logs.sh             # View logs
│       └── seed_demo_plane_ce/ # Demo data seeding
├── plans/
│   └── plane_ce_solution.md    # Original solution design
└── CLAUDE.md                   # This file
```

## Current Branch: `plane_ce`

This is the implementation branch for the Plane CE + AI solution.

### Status

- ✅ Plane CE docker-compose.yml created
- ✅ All deployment scripts updated (up.sh, down.sh, check.sh, logs.sh)
- ✅ Environment configuration (.env) updated
- ✅ AI Service structure created (FastAPI application)
- ✅ Demo data seeding scripts created
- ✅ Comprehensive documentation provided
- ⏳ Ready for testing and refinement

## Key Files

### Configuration
- **`.env`**: All environment variables for services
- **`platform/PLANE_CE_SETUP.md`**: Complete setup and usage guide

### Deployment
- **`platform/scripts/up.sh`**: Start all services (Postgres, Redis, Traefik, Authentik, Plane CE, Plane AI)
- **`platform/scripts/down.sh`**: Stop all services
- **`platform/scripts/check.sh`**: Verify all services are healthy
- **`platform/scripts/logs.sh`**: View logs for any service

### Plane CE
- **`platform/plane-ce/docker-compose.yml`**: Plane CE services (backend, frontend, workers, beat, live)

### AI Service
- **`platform/plane-ai/main.py`**: FastAPI application with AI endpoints
- **`platform/plane-ai/api_client.py`**: Plane CE API client wrapper
- **`platform/plane-ai/docker-compose.yml`**: AI service deployment
- **`platform/plane-ai/README.md`**: AI service documentation

### Demo Data
- **`platform/scripts/seed_demo_plane_ce/run_all.py`**: Main seeding script
- **`platform/scripts/seed_demo_plane_ce/api_client.py`**: API client for seeding
- **`platform/scripts/seed_demo_plane_ce/config.py`**: Seeding configuration
- **`platform/scripts/seed_demo_plane_ce/README.md`**: Demo data documentation

## Quick Start

### 1. Start Services
```bash
cd platform
./scripts/up.sh
```

### 2. Access Plane CE
- URL: https://app.local.test
- Email: admin@plane.local
- Password: PlaneAdmin123!

### 3. Seed Demo Data
```bash
cd platform/scripts/seed_demo_plane_ce
pip install -r requirements.txt
python run_all.py
```

### 4. Check Health
```bash
cd platform
./scripts/check.sh
```

## Development Guidelines

### Adding Features to Plane CE

1. **Custom Extensions**: Plane CE supports plugins and extensions
2. **API Integration**: Use the Plane CE REST API via `api_client.py`
3. **Frontend Customization**: Extend Next.js frontend components
4. **Database Changes**: Use Django migrations for schema changes

### AI Service Development

1. **New Endpoints**: Add routes to `platform/plane-ai/main.py`
2. **LLM Integration**: Use OpenAI SDK in `main.py`
3. **Testing**: Create test files in same directory
4. **Documentation**: Update `platform/plane-ai/README.md`

### Configuration Changes

1. Edit `platform/.env`
2. Restart affected services: `./scripts/down.sh && ./scripts/up.sh`
3. Verify with: `./scripts/check.sh`

## Services Overview

### Plane CE Services
- **plane-backend**: Django REST API server (port 8000)
- **plane-frontend**: Next.js web UI (port 3000)
- **plane-space**: Public sharing/views (port 3001)
- **plane-admin**: Admin dashboard (port 3002)
- **plane-live**: WebSocket server for real-time features (port 3003)
- **plane-worker**: Celery worker for background jobs
- **plane-beat**: Celery beat scheduler

### Infrastructure Services
- **postgres**: PostgreSQL database
- **redis**: Redis cache and message queue
- **traefik**: HTTPS reverse proxy and load balancer
- **authentik**: SSO and identity management

### AI Service
- **plane-ai**: FastAPI application for AI features (port 8001)

## Environment Variables

Key variables in `platform/.env`:

```bash
# Domain
DOMAIN=local.test

# Plane CE Database
PLANE_POSTGRES_DB=plane_ce
PLANE_POSTGRES_USER=plane_ce
PLANE_POSTGRES_PASSWORD=PlanePass123!

# Plane CE Admin
PLANE_ADMIN_EMAIL=admin@plane.local
PLANE_ADMIN_PASSWORD=PlaneAdmin123!

# AI Service
PLANE_AI_SERVICE_TOKEN=test-token
OPENAI_API_KEY=<optional>

# File Storage
AWS_S3_BUCKET_NAME=plane-files
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_S3_ENDPOINT_URL=http://platform-minio:9000
```

## Testing Checklist

### Pre-Deployment
- [ ] All services start without errors: `./scripts/up.sh`
- [ ] Health check passes: `./scripts/check.sh`
- [ ] Can access Plane CE: https://app.local.test
- [ ] Can access AI service: https://ai.local.test

### Functionality
- [ ] Create a project in Plane CE
- [ ] Add users and team members
- [ ] Create issues/tasks
- [ ] Create sprints/cycles
- [ ] Add comments and activities
- [ ] Test AI endpoints (if enabled)
- [ ] Seed demo data successfully

### Data Integrity
- [ ] Database migrations completed
- [ ] No errors in logs
- [ ] Data persistence across restarts
- [ ] File uploads working (if applicable)

## Troubleshooting

### Services Not Starting
```bash
# Check Docker
docker ps -a

# Check logs
./scripts/logs.sh <service_name>

# Restart
./scripts/down.sh && ./scripts/up.sh
```

### API Errors
```bash
# Check API health
curl https://app.local.test/api/health/

# View detailed logs
./scripts/logs.sh plane-backend
```

### Database Issues
```bash
# Check Postgres
./scripts/logs.sh postgres

# Verify connection
docker exec platform-postgres pg_isready -U postgres
```

## Related Documentation

- **Original Solution Design**: `plans/plane_ce_solution.md`
- **Plane CE Setup Guide**: `platform/PLANE_CE_SETUP.md`
- **AI Service Guide**: `platform/plane-ai/README.md`
- **Demo Data Guide**: `platform/scripts/seed_demo_plane_ce/README.md`
- **Platform Walkthrough**: `platform/platform_walkthrough.md`

## Next Steps

1. **Testing**: Verify all services work correctly in local environment
2. **Customization**: Add team-specific workflows and templates
3. **Data Migration**: Migrate data from NocoBase if needed
4. **SSO Setup**: Configure Authentik integration
5. **AI Enhancement**: Enable OpenAI features and test AI endpoints
6. **Production Deployment**: Plan deployment to production environment

## Notes

- Plane CE uses Django backend with PostgreSQL database
- Frontend is Next.js with real-time WebSocket support via `plane-live`
- AI service is independent FastAPI application that can scale separately
- All services communicate via Docker network `proxy`
- Traefik handles HTTPS termination and routing

## Contact & Support

For questions about this implementation, refer to:
- Solution design: `plans/plane_ce_solution.md`
- Component documentation: Individual README.md files
- Configuration: `platform/.env` and compose files

---

**Last Updated**: 2026-04-25  
**Branch**: plane_ce  
**Status**: Implementation in progress
