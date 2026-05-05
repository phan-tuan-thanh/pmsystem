# Sprint 1 — Database & Cache Foundation

**Mục tiêu**: Thiết lập nền tảng hạ tầng, tạo PostgreSQL và Redis services, chuẩn bị environment templates.

**Thời lượng**: 1 tuần (40h)
**Story Points Target**: 13–17 pts
**Deliverables**:
- `docker-compose.postgres.yml`
- `docker-compose.redis.yml`
- `.env.example`, `.env.production`
- `docs/postgres-setup.md`

---

## Epics & User Stories

### Epic 1: PostgreSQL Service Foundation (8 pts)

#### US 1.1 — Create docker-compose.postgres.yml (5 pts)

**User Story**: Là DevOps engineer, tôi cần production-ready PostgreSQL compose file để deploy database với persistence và health checks.

**Acceptance Criteria**:
- [ ] `docker-compose.postgres.yml` tồn tại, syntax hợp lệ (compose v3.8+)
- [ ] Image: `postgres:15` trở lên
- [ ] Volume: `/var/lib/postgresql/data` → `./postgres-data/` trên host
- [ ] Health check: `pg_isready -U postgres`
- [ ] Biến môi trường: `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` từ `.env`
- [ ] Restart policy: `unless-stopped`
- [ ] `docker compose -f docker-compose.postgres.yml up -d` chạy không lỗi
- [ ] Dữ liệu tồn tại sau `down` → `up`

**Tasks**:
- [x] Nghiên cứu DB requirements của Plane CE (xem `yeu_cau.md` → Section DB)
- [x] Tạo `docker-compose.postgres.yml` với cấu trúc cơ bản
- [x] Thêm volume mounts
- [x] Cấu hình health checks
- [x] Set environment variables và defaults
- [x] Test local: compose up, verify data persistence
- [x] Ghi chú volume backup location trong comments

**Points**: 5 | **Assigned**: [TBD] | **Status**: Done

---

#### US 1.2 — Backup Strategy Docs (3 pts)

**User Story**: Là sysadmin, tôi cần tài liệu backup/restore PostgreSQL để vận hành an toàn trong production.

**Acceptance Criteria**:
- [x] `docs/postgres-setup.md` được tạo
- [x] Backup retention policy documented (7–30 ngày)
- [x] Lệnh backup mẫu (`pg_dump`) có ví dụ
- [x] Quy trình restore documented
- [x] Linked từ docs chính

**Tasks**:
- [x] Tạo `docs/postgres-setup.md`
- [x] Viết lệnh `pg_dump` với examples
- [x] Document quy trình restore
- [x] Link từ `CLAUDE.md` và README

**Points**: 3 | **Assigned**: Antigravity | **Status**: Done

---

### Epic 2: Redis Service Foundation (5 pts)

#### US 2.1 — Create docker-compose.redis.yml (5 pts)

**User Story**: Là DevOps engineer, tôi cần Redis service compose file để Plane API có caching và session storage.

**Acceptance Criteria**:
- [ ] `docker-compose.redis.yml` tồn tại, syntax hợp lệ
- [ ] Image: `redis:7-alpine` trở lên
- [ ] Volume: `/data` → `./redis-data/` trên host
- [ ] Health check: `redis-cli ping` trả về `PONG`
- [ ] Persistence: `appendonly yes`
- [ ] Restart policy: `unless-stopped`
- [ ] `docker compose -f docker-compose.redis.yml up -d` chạy không lỗi
- [ ] Dữ liệu tồn tại sau restart

**Tasks**:
- [x] Tạo `docker-compose.redis.yml`
- [x] Thêm Redis persistence config (`appendonly`)
- [x] Cấu hình volume mounts
- [x] Implement health checks
- [x] Set restart policy
- [x] Test local: compose up, verify persistence
- [x] Verify `redis-cli` connect được

**Points**: 5 | **Assigned**: [TBD] | **Status**: Done

---

### Epic 3: Environment Templates (3 pts)

#### US 3.1 — Create .env.example & .env.production (3 pts)

**User Story**: Là developer, tôi cần env config templates để nhanh chóng setup deployment cho các môi trường khác nhau.

**Acceptance Criteria**:
- [x] `.env.example` có đủ variables với comments giải thích
- [x] Cover: PostgreSQL (user, password, db), Redis URL, Plane ports, SECRET_KEY
- [x] `.env.production` có secure defaults (không có blank passwords)
- [x] Variables trong compose files khớp với `.env`
- [x] File `.env.example` commit được vào git; `.env.production` không commit

**Tasks**:
- [x] Tạo `.env.example` với PostgreSQL variables
- [x] Thêm Redis variables
- [x] Thêm Plane service defaults (ports, secrets)
- [x] Tạo `.env.production` với production defaults
- [x] Thêm comments giải thích từng variable
- [x] Verify compose files reference đúng vars
- [x] Document naming convention

**Points**: 3 | **Assigned**: Antigravity | **Status**: Done

---

## Task List theo Ngày

**Day 1 (Thứ Hai)**
- [ ] Sprint Planning meeting
- [ ] US 1.1: Nghiên cứu Plane database requirements
- [ ] US 2.1: Nghiên cứu Redis requirements

**Day 2 (Thứ Ba)**
- [ ] US 1.1: Tạo `docker-compose.postgres.yml`
- [ ] US 1.1: Thêm volumes và health checks
- [ ] US 3.1: Bắt đầu `.env.example` template

**Day 3 (Thứ Tư)**
- [ ] US 1.1: Test PostgreSQL compose locally
- [ ] US 2.1: Tạo `docker-compose.redis.yml`
- [ ] US 2.1: Thêm Redis persistence config

**Day 4 (Thứ Năm)**
- [ ] US 2.1: Test Redis compose locally
- [ ] US 3.1: Hoàn thành `.env` files
- [ ] US 1.2: Bắt đầu `postgres-setup.md`

**Day 5 (Thứ Sáu)**
- [ ] US 1.2: Hoàn thành backup documentation
- [ ] Integration test: compose cả postgres và redis cùng nhau
- [ ] Sprint Review & Demo
- [ ] Sprint Retrospective

---

## Quality Checklist

Trước khi mark task complete:
- [ ] Compose files pass syntax: `docker compose config -f <file>`
- [ ] Không hardcode passwords (dùng `.env`)
- [ ] Health checks defined cho tất cả services
- [ ] Volumes mount đúng
- [ ] Services restart sau machine reboot
- [ ] Documentation links updated

---

## Dependencies & Risks

**Dependencies**:
- US 1.2 phụ thuộc US 1.1 (cần compose file trước khi docs)
- US 3.1 phụ thuộc US 1.1 và US 2.1 (cần biết required env vars)

**Risks**:
- **Docker image availability**: Test pull `postgres:15` và `redis:7-alpine` ngay Day 1
- **Volume mount permissions**: Linux có thể gặp permission issues — document `chown` commands
- **Password complexity**: `.env.production` yêu cầu strong passwords — document rõ

---

## Acceptance & Sign-Off

**Sprint 1 Complete khi**:
- [ ] Tất cả compose files created và tested locally
- [ ] `.env` files không có blank values
- [ ] Documentation viết xong và linked
- [ ] `./scripts/check.sh` nhận diện postgres và redis compose exist
- [ ] Manual test pass: compose both services, health check ok, data persist qua restart

**Sign-Off**: Antigravity — Date: 2026-05-04
