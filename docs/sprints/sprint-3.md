# Sprint 3 — Validation, Testing & Documentation

**Mục tiêu**: End-to-end testing toàn bộ configuration, backup/recovery docs, README, quick-start guide, final validation.

**Phụ thuộc**: Sprint 1 và Sprint 2 phải hoàn thành (tất cả 4 compose files phải có)

**Thời lượng**: 1 tuần (40h)
**Story Points Target**: 8–13 pts
**Deliverables**:
- Full stack validated (bundled + external Traefik modes)
- `README.md`
- `docs/QUICK-START.md`
- `docs/backup-restore.md`
- `docs/VALIDATION-CHECKLIST.md`
- `CLAUDE.md` updated

---

## Epics & User Stories

### Epic 1: Deployment Validation (5 pts)

#### US 1.1 — Test Full Stack (Bundled Traefik Mode) (3 pts)

**User Story**: Là DevOps engineer, tôi cần validate full stack deploy đúng trong bundled Traefik mode để đảm bảo production readiness.

**Acceptance Criteria**:
- [ ] `./scripts/deploy.sh --with-traefik --env production --no-detach` chạy không lỗi
- [ ] 5 services start: postgres, redis, plane-web, plane-api, traefik
- [ ] Health checks pass, không restart loops
- [ ] Traefik routing: plane-web và plane-api accessible qua HTTPS
- [ ] DB connectivity: plane-api query được postgres
- [ ] Redis connectivity: redis-cli connect được
- [ ] File upload: tạo attachment, file lưu trong `./uploads/`
- [ ] Stop/restart cycle: data persist (`./scripts/stop.sh --all` → `./scripts/deploy.sh`)
- [ ] Logs không có critical errors

**Tasks**:
- [ ] Setup fresh test environment (clean `.env`, empty volumes)
- [ ] Chạy full deploy: `./scripts/deploy.sh --with-traefik --env production --no-detach`
- [ ] Monitor logs 5 phút: `docker compose logs -f`
- [ ] Test service health endpoints
- [ ] Test DB connectivity: tạo test project trong Plane
- [ ] Upload file, verify trong `./uploads/`
- [ ] Stop và restart: verify data persist
- [ ] Document mọi issue tìm thấy

**Points**: 3 | **Assigned**: [TBD] | **Status**: Not Started

---

#### US 1.2 — Test External Traefik Mode (2 pts)

**User Story**: Là DevOps engineer, tôi cần validate stack hoạt động với external Traefik để support multi-cluster hoặc shared proxy setups.

**Acceptance Criteria**:
- [ ] External Traefik instance đang chạy (container riêng hoặc VM)
- [ ] `./scripts/deploy.sh --external-traefik --env production` chạy không lỗi
- [ ] Plane services accessible qua external Traefik
- [ ] Routing labels trong `docker-compose.plane.yml` cấu hình đúng

**Tasks**:
- [ ] Setup external Traefik instance
- [ ] Cấu hình external Traefik route đến Plane services
- [ ] Deploy với `--external-traefik` flag
- [ ] Test connectivity qua external proxy
- [ ] Document setup steps trong troubleshooting guide

**Points**: 2 | **Assigned**: [TBD] | **Status**: Not Started

---

### Epic 2: Backup & Recovery Documentation (3 pts)

#### US 2.1 — Document PostgreSQL Backup & Restore (1.5 pts)

**User Story**: Là sysadmin, tôi cần tài liệu backup/restore PostgreSQL đầy đủ để recover từ data loss trong production.

**Acceptance Criteria**:
- [ ] `docs/backup-restore.md` được tạo
- [ ] Lệnh backup: `pg_dump`, `pg_dumpall` với examples
- [ ] Backup frequency: daily minimum
- [ ] Retention policy: 7–30 ngày
- [ ] Backup storage location recommended (local + off-site)
- [ ] Quy trình restore step-by-step
- [ ] Shell script template mẫu
- [ ] RTO và RPO defined

**Tasks**:
- [ ] Tạo `docs/backup-restore.md`
- [ ] Document `pg_dump` với examples
- [ ] Viết backup shell script template
- [ ] Document restore procedure
- [ ] Define backup retention policy
- [ ] Link từ `CLAUDE.md`

**Points**: 1.5 | **Assigned**: [TBD] | **Status**: Not Started

---

#### US 2.2 — Document Uploads Folder Backup (1.5 pts)

**User Story**: Là sysadmin, tôi cần biết cách backup và restore `./uploads/` để recover file attachments.

**Acceptance Criteria**:
- [ ] Backup strategy cho `./uploads/` documented
- [ ] Lệnh tar/rsync với examples
- [ ] Restore procedure documented
- [ ] Synchronization với database backups giải thích
- [ ] Thêm vào `docs/backup-restore.md`

**Tasks**:
- [ ] Document uploads folder backup strategy
- [ ] Cung cấp tar/rsync command examples
- [ ] Giải thích phối hợp backup với database
- [ ] Append vào `backup-restore.md`

**Points**: 1.5 | **Assigned**: [TBD] | **Status**: Not Started

---

### Epic 3: README & Quick Start (3 pts)

#### US 3.1 — Create Root README.md (1.5 pts)

**User Story**: Là new user, tôi cần README để nhanh chóng hiểu project và biết tìm thông tin ở đâu.

**Acceptance Criteria**:
- [ ] `README.md` tạo tại project root
- [ ] Mô tả project: Plane CE deployment infrastructure
- [ ] Quick start ≤ 5 bước
- [ ] Links đến docs: deployment, backup, troubleshooting
- [ ] Architecture diagram (ASCII)
- [ ] Prerequisites listed (Docker, Compose versions)

**Tasks**:
- [ ] Tạo `README.md`
- [ ] Viết project overview (≤ 50 từ)
- [ ] List prerequisites
- [ ] Cung cấp quick-start steps
- [ ] Vẽ ASCII architecture diagram
- [ ] Thêm links đến detailed docs

**Points**: 1.5 | **Assigned**: [TBD] | **Status**: Not Started

---

#### US 3.2 — Create Quick-Start Guide (1.5 pts)

**User Story**: Là DevOps engineer, tôi cần quick-start guide để deploy Plane CE trong < 10 phút cho testing hoặc development.

**Acceptance Criteria**:
- [ ] `docs/QUICK-START.md` được tạo
- [ ] Achievable trong 10 phút
- [ ] Step-by-step commands với giải thích
- [ ] Environment setup instructions
- [ ] Hướng dẫn truy cập Plane CE sau deploy
- [ ] Cleanup instructions
- [ ] Troubleshooting phổ biến

**Tasks**:
- [ ] Tạo `docs/QUICK-START.md`
- [ ] Viết 5-step quick-start
- [ ] Include example `.env` values
- [ ] Document cleanup procedure
- [ ] Thêm common issues và fixes
- [ ] Test: follow guide từ đầu, verify deploy trong < 10 phút

**Points**: 1.5 | **Assigned**: [TBD] | **Status**: Not Started

---

### Epic 4: Final Documentation & Validation (2 pts)

#### US 4.1 — Update CLAUDE.md (1 pt)

**User Story**: Là project maintainer, tôi cần `CLAUDE.md` cập nhật để reflect completion của docker-compose files.

**Acceptance Criteria**:
- [ ] `CLAUDE.md` cập nhật: docker-compose files marked CREATED
- [ ] `CLAUDE.md` cập nhật: `.env` files marked CREATED
- [ ] Links đến documentation mới thêm
- [ ] File status table đúng (không còn "Files Not Yet Present")

**Tasks**:
- [ ] Update "Files Not Yet Present" section trong `CLAUDE.md`
- [ ] Mark tất cả compose và env files là created
- [ ] Thêm links đến deployment và backup docs
- [ ] Review for accuracy

**Points**: 1 | **Assigned**: [TBD] | **Status**: Not Started

---

#### US 4.2 — Create Validation Checklist (1 pt)

**User Story**: Là DevOps engineer, tôi cần validation checklist và troubleshooting guide để diagnose issues và verify deployments.

**Acceptance Criteria**:
- [ ] `docs/VALIDATION-CHECKLIST.md` được tạo
- [ ] Pre-deployment checklist
- [ ] Post-deployment health checks
- [ ] Common issues và solutions documented
- [ ] Links đến logs và debug commands

**Tasks**:
- [ ] Tạo `docs/VALIDATION-CHECKLIST.md`
- [ ] Viết pre-deployment checklist (Docker version, disk, ports)
- [ ] Document health check commands
- [ ] Document common issues:
  - Service không start
  - Port already in use
  - Volume permission issues
  - Network connectivity problems
- [ ] Cung cấp debug commands (`docker compose logs`, `docker ps`, v.v.)

**Points**: 1 | **Assigned**: [TBD] | **Status**: Not Started

---

## Task List theo Ngày

**Day 1 (Thứ Hai)**
- [ ] Sprint Planning meeting
- [ ] US 1.1: Setup fresh test environment
- [ ] US 1.1: Chạy full stack deployment

**Day 2 (Thứ Ba)**
- [ ] US 1.1: Validate tất cả services running
- [ ] US 1.1: Test DB và file upload functionality
- [ ] US 2.1: Bắt đầu backup documentation

**Day 3 (Thứ Tư)**
- [ ] US 1.2: Setup external Traefik
- [ ] US 1.2: Test external Traefik mode
- [ ] US 2.1: Hoàn thành PostgreSQL backup docs
- [ ] US 2.2: Document uploads backup

**Day 4 (Thứ Năm)**
- [ ] US 3.1: Tạo `README.md`
- [ ] US 3.2: Tạo `QUICK-START.md`
- [ ] US 4.1: Update `CLAUDE.md`
- [ ] US 4.2: Tạo validation checklist

**Day 5 (Thứ Sáu)**
- [ ] Final validation: follow `QUICK-START.md` từ đầu, verify hoạt động
- [ ] Stop/restart cycle test: verify data persist
- [ ] Peer review tất cả documentation
- [ ] Sprint Review & Demo
- [ ] Sprint Retrospective

---

## End-to-End Validation Test (Day 5)

**Mục tiêu**: Verify mọi thứ hoạt động cho new user.

```
1. Start với clean machine / clean volumes
2. Đọc README.md → hiểu project
3. Follow QUICK-START.md → deploy trong < 10 phút
4. Verify services: docker compose ps
5. Truy cập Plane CE: https://plane.example.com
6. Tạo test project, upload file
7. Stop và restart → verify data persist
8. Chạy backup script, restore từ backup, verify data recovered
9. Đọc troubleshooting guide → verify trả lời được câu hỏi phổ biến
```

**Pass criteria**: Tất cả bước complete không cần manual intervention ngoài script

---

## Quality Checklist

- [ ] Tất cả tests pass không lỗi
- [ ] Documentation complete và accessible
- [ ] Tất cả links trong docs hoạt động
- [ ] Code references đúng (không stale paths)
- [ ] README và quick-start tested từ đầu
- [ ] Backup procedure tested end-to-end (backup và restore)
- [ ] Troubleshooting guide cover common issues
- [ ] Peer review completed

---

## Acceptance & Sign-Off

**Sprint 3 Complete khi**:
- [ ] Full stack validation pass (bundled và external Traefik)
- [ ] Backup & recovery documented và tested
- [ ] README và QUICK-START complete và tested
- [ ] Validation checklist và troubleshooting guide tạo xong
- [ ] `CLAUDE.md` updated với completion status
- [ ] Tất cả docs peer reviewed
- [ ] Project ready cho production deployment

**Sign-Off**: [Name] — Date: ___________

---

## Post-Sprint 3 Roadmap

Sau Sprint 3, xem [yeu_cau.md](../../yeu_cau.md) Section 13 cho Phase 3–4:
- Monitoring: Prometheus + Grafana
- SSO: Authentik + Microsoft 365 (Entra ID)
- Advanced automation workflows
