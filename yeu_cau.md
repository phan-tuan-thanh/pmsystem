# Project Overview — Plane CE Self-hosted

**Phiên bản**: 2.1 | **Cập nhật**: 2026-05-04

Triển khai Plane CE (Agile PM, open-source thay thế Jira/ClickUp) trên Docker Compose, self-hosted, không MinIO.

---

## Kiến trúc hệ thống

```
User → Traefik (HTTPS) → plane-web (React) + plane-api (Django)
                               ↓                    ↓
                            Redis            PostgreSQL + ./uploads/
```

**SSO flow (Phase 3+)**:
```
User → Plane CE → Authentik (IdP) → Microsoft 365 / Entra ID
```

| Thành phần | Công nghệ | Ghi chú |
|------------|-----------|---------|
| Reverse Proxy | Traefik | Bundled hoặc external |
| Backend | Django (Plane API) | |
| Frontend | React (Plane Web) | |
| Database | PostgreSQL 15+ | |
| Cache | Redis 7+ | |
| Storage | Local filesystem | `./uploads` → `/app/media` |
| IdP/SSO | Authentik | Broker cho M365 — Phase 3 |

---

## Quyết định kiến trúc quan trọng

- **Storage**: Local filesystem (không MinIO) — đủ cho team nhỏ/vừa, đơn giản hơn
- **Traefik**: Hỗ trợ cả bundled (single-node) và external (tổ chức có Traefik tập trung)
- **SSO**: Authentik làm IdP trung gian, federate với Microsoft 365 (Entra ID) — **KHÔNG** direct OIDC M365 → Plane
- **Image tag**: Pin version cụ thể trong `.env`, không dùng `latest` trong production
- **Secrets**: Lưu trong `.env` (không commit), sinh bằng `openssl rand -hex 32`

---

## Tài liệu chi tiết

### Yêu cầu hệ thống
| Tài liệu | Nội dung |
|----------|----------|
| [docs/AGILE-REQUIREMENTS.md](docs/AGILE-REQUIREMENTS.md) | Requirements map đầy đủ (FR/NFR IDs, acceptance criteria, risk register) |

### Sprint Plans
| Tài liệu | Nội dung |
|----------|----------|
| [docs/sprints/planning.md](docs/sprints/planning.md) | Tổng quan sprint, ceremonies, DoR/DoD, backlog priority |
| [docs/sprints/sprint-1.md](docs/sprints/sprint-1.md) | Sprint 1: PostgreSQL, Redis, env templates — task list đầy đủ |
| [docs/sprints/sprint-2.md](docs/sprints/sprint-2.md) | Sprint 2: Plane services, Traefik, staging env — task list đầy đủ |
| [docs/sprints/sprint-3.md](docs/sprints/sprint-3.md) | Sprint 3: Validation, backup docs, README, quick-start — task list đầy đủ |

### Vận hành & Deployment
| Tài liệu | Nội dung |
|----------|----------|
| [CLAUDE.md](CLAUDE.md) | Hướng dẫn scripts, kiến trúc file, data cần backup |
| [docs/deployment.md](docs/deployment.md) | Script options, example flows |

---

## Roadmap (tóm tắt)

| Phase | Tuần | Mục tiêu chính |
|-------|------|----------------|
| **Phase 1** | Tuần 1–2 | Deploy Plane CE + domain + HTTPS + backup cron |
| **Phase 2** | Tuần 3–4 | Stabilize: RBAC, backup test, onboarding |
| **Phase 3a** | Tháng 2 | Authentik SSO + Microsoft 365 (Entra ID) federation |
| **Phase 3b** | Tháng 2 | Monitoring: Prometheus + Grafana |
| **Phase 4** | Tháng 3+ | Automation workflows, AI integration |

Chi tiết từng phase và task list: xem [docs/sprints/](docs/sprints/)

---

## Yêu cầu hạ tầng tối thiểu

| | Minimum | Recommended |
|-|---------|-------------|
| CPU | 2 core | 4–8 core |
| RAM | 4 GB | 8–16 GB |
| Disk | 20 GB SSD | ≥ 100 GB SSD |
| OS | Linux 64-bit (Ubuntu 22.04+) | |
| Docker | 24.0+ | |
| Docker Compose | v2.20+ | |

---

## Dữ liệu phải backup

- **PostgreSQL** — toàn bộ issue, project, user data
- **`./uploads/`** — file attachments (không trong DB)

Backup daily, retention 7–30 ngày. Restore order: DB → uploads → restart.
Xem chi tiết: [docs/sprints/sprint-3.md → Epic 2](docs/sprints/sprint-3.md)

---

---
 
 ## Kỹ thuật chi tiết (Plane v1.3.0)
 
 ### 8.1 Cấu hình Lưu trữ (Storage)
 
 Theo yêu cầu hệ thống không sử dụng MinIO, Plane CE được cấu hình sử dụng **Local Filesystem Storage**:
 - Thư mục Host: `./uploads/`
 - Thư mục Container: `/app/media/`
 - Biến môi trường: `USE_MINIO=0`, `STORAGE_TYPE=local` (hoặc cấu hình tương đương cho v1.3.0).
 
 ### 8.2 Docker Image Tags (Stable v1.3.0)
 
 | Dịch vụ | Image Name | Tag |
 |---------|------------|-----|
 | `plane-web` | `makeplane/plane-frontend` | `v1.3.0` |
 | `plane-api` | `makeplane/plane-backend` | `v1.3.0` |
 | `plane-worker`| `makeplane/plane-backend` | `v1.3.0` |
 | `plane-space` | `makeplane/plane-space` | `v1.3.0` |
 | `plane-live` | `makeplane/plane-live` | `v1.3.0` |
 | `plane-admin` | `makeplane/plane-admin` | `v1.3.0` |
 
 ---
 
 ## KPI

| KPI | Mục tiêu | Cách đo |
|-----|----------|---------|
| Adoption rate | ≥ 80% | % member login ≥ 1 lần/tuần |
| Sprint completion rate | ≥ 70% | Completed / planned issues |
| System uptime | ≥ 99% | Grafana / UptimeRobot |
| Backup success rate | 100% | Log backup hàng tuần |
| SSO login success | ≥ 99% | Authentik audit log (Phase 3+) |
