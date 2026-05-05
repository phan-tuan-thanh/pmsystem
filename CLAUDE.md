# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Deployment infrastructure for **Plane CE** (self-hosted Agile project management — open-source alternative to Jira/ClickUp). The repo contains only orchestration scripts and documentation; the actual Plane application code comes from the upstream Plane project.

Storage is local filesystem (`./uploads` → `/app/media` in containers) — no MinIO/S3.

## Scripts

Scripts in [scripts/](scripts/) are already executable. Run from the repo root:

```sh
# Pre-deployment validation (docker daemon, compose files, optional Traefik reachability)
./scripts/check.sh
./scripts/check.sh --traefik-url https://traefik.example.com

# Deploy full stack with bundled Traefik (good for single-node / local testing)
./scripts/deploy.sh --with-traefik --env production

# Deploy full stack using an existing central Traefik
./scripts/deploy.sh --external-traefik --env production

# Deploy a single service (plane-api, plane-web, postgres, redis…)
./scripts/deploy-service.sh --service plane-api --external-traefik

# Stop
./scripts/stop.sh --all
./scripts/stop.sh --service plane-api
```

Default for `--detach` is on (background). Pass `--no-detach` to stream logs.

## Architecture

Five Docker Compose files, each owning one concern:

| File | Services |
|---|---|
| `docker-compose.postgres.yml` | `postgres` |
| `docker-compose.redis.yml` | `redis` |
| `docker-compose.plane.yml` | `plane-web`, `plane-api` |
| `docker-compose.traefik.yml` | `traefik` (optional — bundled mode) |

`deploy.sh` merges them with `-f` flags. Services communicate over an internal Docker network; only Traefik exposes public ports (HTTPS mandatory).

**Traefik modes:**
- `--with-traefik` — spins up `docker-compose.traefik.yml` as part of this project (simplest, single-node)
- `--external-traefik` — omits that file; assumes a central Traefik instance already running elsewhere with labels/entrypoints configured in `docker-compose.plane.yml`

## Files Not Yet Present

The four `docker-compose.*.yml` files and any `.env` files are not yet in this repo and must be created. `check.sh` will flag missing compose files before a deploy.

## Data That Must Be Backed Up

- PostgreSQL database (Xem: [docs/postgres-setup.md](docs/postgres-setup.md))
- `./uploads/` directory (file attachments stored as local volume)

Backup daily; retain 7–30 days. Restore order: DB → uploads folder → restart services.

---

## Sprint Agent

File: [agents/sprint-agent.yml](agents/sprint-agent.yml)

Để dùng, tag file vào chat rồi gõ command:

```
@agents/sprint-agent.yml

process-sprint 1
```

### Commands

| Command | Loại | Mục đích |
|---------|------|----------|
| `process-sprint {id}` | 🔍 Phân tích | Xác định trạng thái sprint và bước tiếp theo |
| `plan-sprint {id}` | 🔍 Phân tích | Lập kế hoạch từ backlog + capacity |
| `start-sprint {id}` | ✏️ Ghi file | Kích hoạt sprint (set In Progress) |
| `execute-task {id} {us_id}` | ⚡ Thực thi | **Tạo deliverable files + mark tasks done** |
| `validate-task {id} {us_id}` | ✅ Kiểm tra | Xác minh deliverables theo acceptance criteria |
| `run-sprint {id}` | ⚡ Thực thi | **Thực thi toàn bộ sprint theo thứ tự** |
| `update-sprint {id}` | 🔍 Phân tích | Cập nhật tiến độ từ trạng thái file hiện tại |
| `detect-risk {id}` | 🔍 Phân tích | Phát hiện rủi ro dựa trên dữ liệu thực tế |
| `replan-sprint {id}` | ✏️ Ghi file | Điều chỉnh scope giữa sprint (cần xác nhận) |
| `review-sprint {id}` | 🔍 Phân tích | Đánh giá kết quả sau sprint |
| `report-sprint {id}` | ✏️ Ghi file | Xuất báo cáo ra `docs/reports/sprint-{id}-report.md` |

### Thứ tự điển hình

```
process-sprint {id}
      ↓
plan-sprint {id}   →   start-sprint {id}
      ↓
run-sprint {id}                          ← thực thi toàn bộ sprint
  └─ execute-task {id} {us_id}           ← tạo từng file deliverable
  └─ validate-task {id} {us_id}          ← kiểm tra acceptance criteria
      ↓
update-sprint {id}   →   detect-risk {id}   →   replan-sprint {id}
      ↓
review-sprint {id}   →   report-sprint {id}
```

### Data sources (agent tự đọc, không cần chỉ định thủ công)

| Dữ liệu | File | Dùng bởi |
|---------|------|----------|
| Sprint detail | `docs/sprints/sprint-{id}.md` | tất cả commands |
| Backlog / requirements | `docs/AGILE-REQUIREMENTS.md` | plan, execute, validate |
| Planning & capacity | `docs/sprints/planning.md` | plan, update, detect-risk |
| Architecture & tech decisions | `yeu_cau.md` | execute-task |
| File structure & arch notes | `CLAUDE.md` | execute-task |
| Reports (output) | `docs/reports/sprint-{id}-report.md` | report-sprint |
| Deliverables (output) | paths từ acceptance criteria | execute-task |
