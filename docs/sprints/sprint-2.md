# Sprint 2 — Application Services & Traefik [COMPLETED]

**Mục tiêu**: Tạo Plane application services (web + API) và Traefik reverse proxy, hoàn thiện environment files cho staging.

**Phụ thuộc**: Sprint 1 phải hoàn thành trước (postgres, redis compose files cần có)

**Thời lượng**: 1 tuần (40h)
**Story Points Target**: 13–17 pts
**Deliverables**:
- `docker-compose.plane.yml`
- `docker-compose.traefik.yml`
- `.env.staging`
- `docs/plane-services-setup.md`
- `docs/traefik-setup.md`

---

## Epics & User Stories

### Epic 1: Plane Application Services (10 pts)

#### US 1.1 — Create docker-compose.plane.yml (7 pts)

**User Story**: Là DevOps engineer, tôi cần compose file cho Plane web + API để deploy toàn bộ Plane CE với đúng networking và volume mounts.

**Acceptance Criteria**:
- [ ] `docker-compose.plane.yml` có services `plane-web` và `plane-api`
- [x] Dùng official Plane CE images (v1.3.0) (xem `yeu_cau.md` Section 8.2 cho image tags)
- [ ] `plane-web`: expose port 3000 (internal, Traefik route HTTPS)
- [ ] `plane-api`: expose port 8000 (internal)
- [ ] Volume: `./uploads` → `/app/media` (file attachments)
- [ ] Env vars reference `.env` file (`DATABASE_URL`, `REDIS_URL`, `SECRET_KEY`)
- [ ] Cả hai services có `depends_on` postgres và redis
- [ ] Network: cùng internal Docker network
- [ ] Health checks: `plane-api` → `/api/health/`, `plane-web` → `/`
- [ ] Restart policy: `unless-stopped`
- [ ] `docker compose -f docker-compose.plane.yml up -d` chạy không lỗi

**Tasks**:
- [x] Nghiên cứu Plane CE image tags và env requirements (v1.3.0)
- [ ] Tạo `docker-compose.plane.yml` base structure
- [ ] Thêm `plane-web` service (port 3000, env vars)
- [ ] Thêm `plane-api` service (port 8000, env vars)
- [ ] Cấu hình volume mount cho uploads
- [ ] Thêm `depends_on` postgres và redis
- [ ] Implement health checks
- [ ] Test local: verify services start, health checks pass, network connectivity
- [ ] Verify uploads folder writable

**Points**: 7 | **Assigned**: Antigravity | **Status**: Completed

---

#### US 1.2 — Document Plane Services Setup (3 pts)

**User Story**: Là sysadmin, tôi cần tài liệu cấu hình Plane services để customize settings cho deployment.

**Acceptance Criteria**:
- [ ] `docs/plane-services-setup.md` được tạo
- [ ] Env vars documented: `DATABASE_URL`, `REDIS_URL`, `SECRET_KEY`, v.v.
- [ ] Volume mount strategy giải thích (uploads folder)
- [ ] Network architecture documented (internal Docker network)
- [ ] Health check endpoints documented
- [ ] Service interdependencies giải thích (web → api → postgres/redis)

**Tasks**:
- [ ] Tạo `docs/plane-services-setup.md`
- [ ] Document từng env variable với examples
- [ ] Giải thích volume mount strategy
- [ ] Vẽ ASCII network diagram
- [ ] Link từ `CLAUDE.md`

**Points**: 3 | **Assigned**: Antigravity | **Status**: Completed

---

### Epic 2: Traefik Reverse Proxy (5 pts)

#### US 2.1 — Create docker-compose.traefik.yml với HTTPS (5 pts)

**User Story**: Là DevOps engineer, tôi cần Traefik reverse proxy để expose Plane services với HTTPS và TLS termination.

**Acceptance Criteria**:
- [ ] `docker-compose.traefik.yml` có Traefik service
- [ ] Image: `traefik:v3.x` (hoặc mới nhất stable)
- [ ] Expose ports: 80 (HTTP) và 443 (HTTPS)
- [ ] HTTPS: self-signed cho dev, Let's Encrypt cho prod
- [ ] Routing rules:
  - `plane.example.com` → `plane-web:3000`
  - `plane.example.com/api/` → `plane-api:8000`
- [ ] HTTP redirect sang HTTPS
- [ ] Volumes: `/var/run/docker.sock`, `./traefik/` cho config + certs
- [ ] Network: attached cùng internal network với plane services
- [ ] Service start không lỗi

**Tasks**:
- [ ] Tạo `docker-compose.traefik.yml`
- [ ] Cấu hình port mapping (80, 443)
- [ ] Setup Traefik static config (entrypoints, TLS)
- [ ] Thêm routing rules cho plane-web và plane-api
- [ ] Cấu hình HTTP→HTTPS redirect
- [ ] Mount Docker socket cho auto-discovery
- [ ] Test local: `curl https://plane.local` (HTTPS ok, cert warning chấp nhận được trong dev)
- [ ] Test routing đến cả hai services

**Points**: 5 | **Assigned**: Antigravity | **Status**: Completed

---

### Epic 3: Environment Expansion — Staging (2 pts)

#### US 3.1 — Create .env.staging & Complete .env.production (2 pts)

**User Story**: Là developer, tôi cần staging và production env files để deploy đúng cấu hình cho từng môi trường.

**Acceptance Criteria**:
- [ ] `.env.staging` tạo với staging-appropriate defaults
- [ ] `.env.production` cập nhật đủ variables (plane-web, plane-api, traefik)
- [ ] Không hardcode secrets — dùng placeholders `PLACEHOLDER_CHANGE_ME`
- [ ] Comments giải thích từng variable
- [ ] Tất cả vars trong compose files đều có trong `.env`
- [ ] Không có blank values trong production defaults

**Tasks**:
- [ ] Cập nhật `.env.example` từ Sprint 1 với plane service vars
- [ ] Tạo `.env.staging` với staging defaults
- [ ] Hoàn thiện `.env.production`
- [ ] Cross-check compose files reference đúng vars
- [ ] Document required vs optional variables

**Points**: 2 | **Assigned**: Antigravity | **Status**: Completed

---

## Task List theo Ngày

**Day 1 (Thứ Hai)**
- [x] Sprint Planning meeting
- [x] US 1.1: Nghiên cứu Plane CE image tags và config requirements
- [x] US 2.1: Review Traefik v3 documentation

**Day 2 (Thứ Ba)**
- [x] US 1.1: Tạo `docker-compose.plane.yml` base
- [x] US 1.1: Thêm plane-web service
- [x] US 3.1: Cập nhật `.env` files với plane service vars

**Day 3 (Thứ Tư)**
- [x] US 1.1: Thêm plane-api service
- [x] US 1.1: Cấu hình volumes và depends_on
- [x] US 2.1: Tạo `docker-compose.traefik.yml`

**Day 4 (Thứ Năm)**
- [x] US 2.1: Cấu hình Traefik routing rules
- [x] US 2.1: Test Traefik với HTTPS
- [x] US 1.1: Test plane services với Traefik
- [x] US 1.2: Bắt đầu documentation

**Day 5 (Thứ Sáu)**
- [x] US 1.2: Hoàn thành plane services documentation
- [x] Integration test: tất cả 5 services cùng nhau (postgres, redis, plane-web, plane-api, traefik)
- [x] US 3.1: Finalize `.env` files
- [x] Sprint Review & Demo
- [x] Sprint Retrospective

---

## Integration Test (End of Sprint 2)

**Mục tiêu**: Verify tất cả services hoạt động cùng nhau.

```sh
# 1. Copy env
cp .env.staging .env

# 2. Deploy full stack
docker compose \
  -f docker-compose.postgres.yml \
  -f docker-compose.redis.yml \
  -f docker-compose.plane.yml \
  -f docker-compose.traefik.yml \
  up -d

# 3. Wait 30s, then check
curl -i http://localhost:80            # should redirect to HTTPS
curl -k -i https://localhost:443       # should return plane-web

docker compose logs plane-api          # no errors
docker compose logs plane-web          # no errors
ls -la ./uploads/                      # writable

# 4. Stop và verify persistence
docker compose down
ls ./postgres-data/                    # data còn đó
ls ./redis-data/                       # data còn đó
```

**Pass criteria**:
- [ ] HTTP redirect sang HTTPS
- [ ] Plane CE accessible qua browser (ignore SSL warning nếu dùng self-signed)
- [ ] Không có error trong logs
- [ ] Uploads folder writable
- [ ] Data persist sau `down`

---

## Quality Checklist

- [ ] Tất cả compose files pass `docker compose config -f <file>`
- [ ] Không hardcode secrets
- [ ] Health checks cho tất cả services
- [ ] Network connectivity verified
- [ ] Traefik routing: cả plane-web và plane-api accessible
- [ ] HTTPS hoạt động
- [ ] Docker socket mount documented (security implications)
- [ ] Documentation updated

---

## Dependencies & Risks

**Dependencies**:
- US 1.1 phụ thuộc Sprint 1 (postgres, redis compose phải có)
- US 2.1 phụ thuộc US 1.1 (routing đến plane services)
- US 3.1 phụ thuộc US 1.1 và 2.1 (biết đủ env vars)

**Risks**:
- **Plane image availability**: Verify registry Day 1 — có thể cần credentials
- **Traefik routing complexity**: Test từng bước, không config all-at-once
- **SSL cert**: Self-signed → browser warning bình thường trong dev; Let's Encrypt cho prod
- **Docker socket security**: Document security implications; rootless Docker nếu được

---

## Acceptance & Sign-Off

**Sprint 2 Complete khi**:
- [ ] 4/4 compose files (postgres, redis, plane, traefik) created và tested
- [ ] Tất cả `.env` files complete, không blank trong production
- [ ] Integration test pass: 5 services start, network ok, HTTPS ok
- [ ] Documentation complete và linked
- [ ] Peer review passed

**Sign-Off**: [Name] — Date: ___________
