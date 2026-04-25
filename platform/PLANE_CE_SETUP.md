# Plane CE + AI Solution Setup Guide

Complete guide for deploying and using the Plane CE + AI Agile project management platform.

## 📋 Overview

This solution replaces NocoBase with **Plane CE** (open-source project management) enhanced with **AI-powered features** for Agile teams.

### Components

- **Plane CE**: Complete project management platform with Agile features
- **Plane AI Service**: AI-powered enhancements (issue generation, sprint planning, metrics)
- **Authentik**: SSO and identity management
- **PostgreSQL**: Primary database
- **Redis**: Caching and job queue
- **Traefik**: Reverse proxy and HTTPS routing

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- 8GB+ RAM recommended
- Port 80, 443 available
- Domain name (or use `local.test` for local development)

### Startup

```bash
# Navigate to platform directory
cd platform

# Start all services
./scripts/up.sh

# Check status
./scripts/check.sh

# View logs
./scripts/logs.sh <service_name>
```

### Access Services

| Service | URL | Credentials |
|---------|-----|-------------|
| Plane CE | https://app.local.test | admin@plane.local / PlaneAdmin123! |
| Plane AI | https://ai.local.test | API service |
| Authentik | https://auth.local.test | Configure first run |
| Traefik Dashboard | https://traefik.local.test/dashboard/ | - |

## 📦 Directory Structure

```
platform/
├── .env                          # Environment configuration
├── compose.shared.yml            # Shared Docker Compose settings
├── docker-compose.yml            # (optional) Master compose file
│
├── traefik/                      # Reverse proxy & HTTPS
│   └── docker-compose.yml
├── authentik/                    # SSO & Identity
│   └── docker-compose.yml
├── postgres/                     # Database
│   └── docker-compose.yml
├── redis/                        # Cache & Queue
│   └── docker-compose.yml
│
├── plane-ce/                     # Plane CE Services
│   ├── docker-compose.yml
│   └── logs/                     # Service logs
│
├── plane-ai/                     # AI Service
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── main.py
│   ├── api_client.py
│   ├── requirements.txt
│   └── README.md
│
├── scripts/                      # Management scripts
│   ├── up.sh                     # Start all services
│   ├── down.sh                   # Stop all services
│   ├── check.sh                  # Health check
│   ├── logs.sh                   # View service logs
│   ├── seed_demo/                # Legacy NocoBase seed (reference)
│   └── seed_demo_plane_ce/       # Plane CE demo seeding
│       ├── run_all.py
│       ├── api_client.py
│       ├── config.py
│       ├── requirements.txt
│       └── README.md
│
└── PLANE_CE_SETUP.md            # This file
```

## ⚙️ Configuration

### Environment Variables (`.env`)

```bash
# Domain Configuration
DOMAIN=local.test                    # Change to your domain
TZ=Asia/Ho_Chi_Minh                 # Timezone

# Plane CE Database
PLANE_POSTGRES_DB=plane_ce
PLANE_POSTGRES_USER=plane_ce
PLANE_POSTGRES_PASSWORD=PlanePass123!
PLANE_SECRET_KEY=<generate-random-key>
PLANE_ADMIN_EMAIL=admin@plane.local
PLANE_ADMIN_PASSWORD=PlaneAdmin123!

# Plane AI Service
PLANE_AI_SERVICE_TOKEN=<your-api-token>
OPENAI_API_KEY=<optional-for-llm-features>

# File Storage (S3/MinIO)
AWS_S3_BUCKET_NAME=plane-files
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=minioadmin
AWS_S3_ENDPOINT_URL=http://platform-minio:9000

# Email Configuration (optional)
SMTP_HOST=localhost
SMTP_PORT=587
SMTP_USER=noreply@plane.local
```

### Updating Configuration

```bash
# Edit .env file
nano .env

# Restart affected services
./scripts/down.sh
./scripts/up.sh
```

## 📊 Demo Data Seeding

Populate Plane CE with realistic demo data:

```bash
# Navigate to seed script directory
cd platform/scripts/seed_demo_plane_ce

# Install dependencies
pip install -r requirements.txt

# Seed demo data
python run_all.py

# Seed with reset (clears and recreates)
python run_all.py --reset
```

Creates:
- 30 demo users (with Agile roles)
- 20 sample projects
- ~85 sprints
- ~1000 issues/tasks
- 500 comments

## 🤖 AI Service Features

### Available Endpoints

1. **Generate Issue Description**
   - AI-assisted issue writing
   - Auto-generated acceptance criteria
   - Story point estimation

2. **Priority Analysis**
   - Intelligent backlog ranking
   - Business context evaluation
   - Dependency analysis

3. **Sprint Planning**
   - Team velocity analysis
   - Capacity optimization
   - Risk assessment

4. **Agile Metrics**
   - Velocity trends
   - Cycle time analysis
   - Team utilization

5. **Retrospective Suggestions**
   - Automated insights
   - Improvement recommendations
   - Action item suggestions

### Using AI Features

```bash
# Check AI service health
curl https://ai.local.test/health/

# Generate issue description
curl -X POST https://ai.local.test/api/v1/generate-issue-description \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Implement authentication",
    "context": "OAuth2 with Authentik",
    "project_type": "backend"
  }'

# Get agile metrics
curl https://ai.local.test/api/v1/agile-metrics/ws123/proj123
```

## 🔍 Health Checks

### Verify All Services

```bash
./scripts/check.sh
```

Expected output:
```
✅ postgres: running
✅ redis: running
✅ traefik: running
✅ authentik-server: running
✅ plane-backend: running
✅ plane-frontend: running
✅ plane-ai: running
✅ Postgres: Ready
✅ Redis: Ready
✅ Plane CE: Reachable
✅ Plane AI: Reachable
```

### View Logs

```bash
# Plane CE backend logs
./scripts/logs.sh plane-backend

# AI service logs
./scripts/logs.sh plane-ai

# All Traefik activity
./scripts/logs.sh traefik
```

## 🔐 Security Setup

### HTTPS Configuration

Certificates are auto-generated by Traefik with Let's Encrypt.

For local development with self-signed certificates:

```bash
# Allow insecure certificates
export CURL_CA_BUNDLE=""
curl -k https://app.local.test
```

### Initial Setup

1. **Access Plane CE**: https://app.local.test
2. **Login**: admin@plane.local / PlaneAdmin123!
3. **Create Workspace**: Set up your first workspace
4. **Invite Team**: Add users and assign roles
5. **Connect Authentik**: Configure SSO (optional)

## 📈 Agile Workflow Example

### 1. Create Project

```
Dashboard → New Project → Select Template
```

### 2. Setup Team

```
Settings → Members → Invite users with roles
```

### 3. Create Backlog

```
Backlog → Add Issues → Use AI to generate descriptions
```

### 4. Plan Sprint

```
Sprints → Plan Sprint → Add issues → Use AI recommendations
```

### 5. Execute Sprint

```
Board → Move issues → Update status → Add comments
```

### 6. Close Sprint

```
Sprint Summary → View metrics → Retrospective → Get AI insights
```

## 🛠️ Development Mode

### Local Development Without Docker

```bash
# 1. Setup Python environment
python -m venv venv
source venv/bin/activate

# 2. Install AI service dependencies
cd platform/plane-ai
pip install -r requirements.txt

# 3. Configure environment
export PLANE_API_BASE_URL=https://app.local.test/api
export OPENAI_API_KEY=sk-...

# 4. Run AI service
python main.py
```

AI service will be available at `http://localhost:8001`

## 📋 Management Commands

### Start Services
```bash
./scripts/up.sh
```

### Stop Services
```bash
./scripts/down.sh
```

### Check Health
```bash
./scripts/check.sh
```

### View Logs
```bash
./scripts/logs.sh <service_name>
```

Available services:
- postgres, redis, traefik, authentik
- plane-backend, plane-worker, plane-beat
- plane-frontend, plane-space, plane-admin, plane-live
- plane-ai

## 🐛 Troubleshooting

### Services Won't Start

```bash
# Check Docker resources
docker system df

# Check port conflicts
lsof -i :80 :443

# Restart all services
./scripts/down.sh
./scripts/up.sh
```

### Plane CE Not Responsive

```bash
# Check backend logs
./scripts/logs.sh plane-backend

# Restart database
./scripts/logs.sh postgres
docker compose -p platform -f postgres/docker-compose.yml restart
```

### AI Service Errors

```bash
# Check AI logs
./scripts/logs.sh plane-ai

# Verify API connectivity
curl https://ai.local.test/health/
```

### Database Issues

```bash
# Check database connection
docker exec platform-postgres pg_isready -U postgres

# View Postgres logs
./scripts/logs.sh postgres

# Restart Postgres
docker compose -p platform -f postgres/docker-compose.yml restart
```

## 📚 Additional Resources

- [Plane CE Documentation](https://docs.plane.so)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [Traefik Documentation](https://doc.traefik.io/)
- [Authentik Documentation](https://goauthentik.io/)

## 🎯 Next Steps

1. **Seed Demo Data**: Use `seed_demo_plane_ce` to populate sample projects
2. **Configure SSO**: Integrate with Authentik for single sign-on
3. **Customize Agile**: Add team-specific workflows and templates
4. **Enable AI Features**: Configure OpenAI API key for LLM features
5. **Monitor Metrics**: Setup dashboards for team metrics and velocity

## 📝 Migrating from NocoBase

If migrating from the previous NocoBase setup:

1. **Backup NocoBase Data**: Export existing data
2. **Review Legacy Seed**: See `scripts/seed_demo/README.md` for reference
3. **Plan Migration**: Map NocoBase tables to Plane CE structure
4. **Test Thoroughly**: Validate data integrity after migration
5. **Communicate Changes**: Inform team of new platform features

## 🎓 Learning Agile with This Platform

The reference demo project includes:
- Complete examples of all Agile roles
- Sprint history with metrics
- Burndown charts and velocity trends
- Retrospective templates
- Team performance benchmarks

Use it as a learning resource for implementing Agile practices.

## 📞 Support

For issues or questions:

1. Check logs: `./scripts/logs.sh <service>`
2. Review health: `./scripts/check.sh`
3. Consult documentation in each service's README.md
4. Check Docker Compose configuration

---

**Version**: 1.0.0  
**Last Updated**: 2026-04-25  
**Maintainer**: Platform Team
