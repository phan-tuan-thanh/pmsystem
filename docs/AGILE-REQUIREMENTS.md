# Agile Requirements Map

**Project**: Plane CE Deployment Infrastructure
**Cập nhật**: 2026-05-04
**Tổng quan dự án**: [yeu_cau.md](../yeu_cau.md)
**Sprint plans**: [docs/sprints/](sprints/)

---

## Functional Requirements

| Req ID | Yêu cầu | Sprint | Priority | Acceptance Criteria |
|--------|---------|--------|----------|---------------------|
| FR-1 | `docker-compose.postgres.yml` | 1 | Critical | Syntax valid, health check pass, data persist |
| FR-2 | `docker-compose.redis.yml` | 1 | Critical | Syntax valid, appendonly, data persist |
| FR-3 | `docker-compose.plane.yml` (web + api) | 2 | Critical | 2 services, volume uploads, depends_on |
| FR-4 | `docker-compose.traefik.yml` | 2 | Critical | HTTPS, routing plane-web + plane-api |
| FR-5 | `.env` templates (.example, .production, .staging) | 1–2 | Critical | Không blank, comments đầy đủ, không commit secrets |
| FR-6 | HTTPS qua Traefik | 2 | High | HTTP redirect HTTPS, cert valid |
| FR-7 | Persistent volumes (postgres, redis, uploads) | 1–2 | Critical | Data survive `docker compose down/up` |
| FR-8 | Full stack deployment validation | 3 | High | Cả bundled và external Traefik mode |
| FR-9 | Deployment documentation | 1–3 | High | README + QUICK-START deployable < 10 phút |
| FR-10 | Backup & recovery documentation | 3 | High | Procedure tested end-to-end |

---

## Non-Functional Requirements

| Req ID | Yêu cầu | Sprint | Priority | Acceptance Criteria |
|--------|---------|--------|----------|---------------------|
| NFR-1 | Health checks cho tất cả services | 1–2 | High | postgres, redis, plane-api, plane-web |
| NFR-2 | Auto-restart on failure (`unless-stopped`) | 1–2 | High | Services tự restart sau crash |
| NFR-3 | Data persist qua restart cycles | 1–3 | Critical | Volumes không mất sau `down/up` |
| NFR-4 | HTTPS bắt buộc cho public endpoints | 2 | Critical | Không expose HTTP ra ngoài |
| NFR-5 | Documentation luôn cập nhật | 3 | High | Links hoạt động, không stale content |
| NFR-6 | Deploy time < 10 phút từ quick-start | 3 | Medium | Tested từ fresh environment |
| NFR-7 | Hỗ trợ bundled và external Traefik | 2–3 | Medium | Cả hai mode validated |

---

## Sprint → Deliverable Mapping

| Sprint | File deliverables | Docs deliverables |
|--------|-------------------|-------------------|
| Sprint 1 | `docker-compose.postgres.yml`, `docker-compose.redis.yml`, `.env.example`, `.env.production` | `docs/postgres-setup.md` |
| Sprint 2 | `docker-compose.plane.yml`, `docker-compose.traefik.yml`, `.env.staging` | `docs/plane-services-setup.md`, `docs/traefik-setup.md` |
| Sprint 3 | (validation only) | `README.md`, `docs/QUICK-START.md`, `docs/backup-restore.md`, `docs/VALIDATION-CHECKLIST.md` |

---

## Risk Register

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|-----------|
| Plane image không có trong registry | High | Medium | Verify Day 1 Sprint 2; document registry/credentials |
| Volume permission issues (Linux) | Medium | Medium | Document `chown` commands, test sớm |
| Traefik routing complexity | Medium | Medium | Test từng bước, không config all-at-once |
| Backup không thực sự recoverable | High | Low | Test restore end-to-end trong Sprint 3 |
| Plane CE version break change | Medium | Low | Pin version trong `.env`, test upgrade trên staging |

---

## Success Metrics (End of Sprint 3)

- [ ] 4/4 docker-compose files: created, tested, production-ready
- [ ] 3/3 env files complete và không có blank secrets
- [ ] Full stack deploy qua `./scripts/deploy.sh` không cần thao tác tay
- [ ] 5/5 services chạy với health checks passing
- [ ] Data persist qua stop/restart cycle
- [ ] HTTPS functional (bundled và external Traefik)
- [ ] Backup & recovery tested end-to-end
- [ ] Quick-start guide deployable trong < 10 phút

---

## Files to Create (checklist)

**Docker Compose (4)**:
- [ ] `docker-compose.postgres.yml` — Sprint 1
- [ ] `docker-compose.redis.yml` — Sprint 1
- [ ] `docker-compose.plane.yml` — Sprint 2
- [ ] `docker-compose.traefik.yml` — Sprint 2

**Environment (3)**:
- [ ] `.env.example` — Sprint 1
- [ ] `.env.production` — Sprint 1–2
- [ ] `.env.staging` — Sprint 2

**Documentation (7)**:
- [ ] `README.md` — Sprint 3
- [ ] `docs/postgres-setup.md` — Sprint 1
- [ ] `docs/plane-services-setup.md` — Sprint 2
- [ ] `docs/traefik-setup.md` — Sprint 2
- [ ] `docs/QUICK-START.md` — Sprint 3
- [ ] `docs/backup-restore.md` — Sprint 3
- [ ] `docs/VALIDATION-CHECKLIST.md` — Sprint 3

**Files to Update**:
- [ ] `CLAUDE.md` — Sprint 3 (mark files created)
