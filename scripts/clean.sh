#!/bin/sh
# clean.sh — Xóa các thư mục và tài nguyên Docker được tạo khi triển khai.
#
# Usage:
#   ./scripts/clean.sh --data          # Xóa DB + cache + MQ data
#   ./scripts/clean.sh --uploads       # Xóa file đính kèm người dùng
#   ./scripts/clean.sh --certs         # Xóa TLS certs của Traefik
#   ./scripts/clean.sh --network       # Xóa Docker network plane-network
#   ./scripts/clean.sh --images        # Xóa Docker images của Plane
#   ./scripts/clean.sh --all           # Xóa tất cả (full reset)
#   ./scripts/clean.sh --all --yes     # Bỏ qua confirm prompt

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# ── flags ──────────────────────────────────────────────────────────────────────
DO_DATA=0
DO_UPLOADS=0
DO_CERTS=0
DO_NETWORK=0
DO_IMAGES=0
YES=0

if [ $# -eq 0 ]; then
  echo "Usage: $0 [--data] [--uploads] [--certs] [--network] [--images] [--all] [--yes]"
  echo ""
  echo "  --data      Xóa postgres-data/, redis-data/, rabbitmq_data/"
  echo "  --uploads   Xóa uploads/ (file đính kèm người dùng)"
  echo "  --certs     Xóa traefik/ (TLS certificates)"
  echo "  --network   Xóa Docker network plane-network"
  echo "  --images    Xóa Docker images của Plane (giải phóng disk)"
  echo "  --all       Tất cả các mục trên"
  echo "  --yes       Bỏ qua xác nhận"
  exit 0
fi

while [ "$1" != "" ]; do
  case "$1" in
    --data)    DO_DATA=1 ;;
    --uploads) DO_UPLOADS=1 ;;
    --certs)   DO_CERTS=1 ;;
    --network) DO_NETWORK=1 ;;
    --images)  DO_IMAGES=1 ;;
    --all)     DO_DATA=1; DO_UPLOADS=1; DO_CERTS=1; DO_NETWORK=1; DO_IMAGES=1 ;;
    --yes|-y)  YES=1 ;;
    -h|--help)
      "$0"
      exit 0 ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1 ;;
  esac
  shift
done

# ── helpers ────────────────────────────────────────────────────────────────────
warn() { printf '\033[33m[WARN]\033[0m %s\n' "$1"; }
info() { printf '\033[36m[INFO]\033[0m %s\n' "$1"; }
ok()   { printf '\033[32m[ OK ]\033[0m %s\n' "$1"; }
err()  { printf '\033[31m[ERR ]\033[0m %s\n' "$1" >&2; }

remove_dir() {
  dir="$1"
  if [ -d "$dir" ]; then
    rm -rf "$dir"
    ok "Đã xóa $dir"
  else
    info "Không tìm thấy $dir, bỏ qua."
  fi
}

# ── pre-flight: containers phải dừng trước ────────────────────────────────────
RUNNING=$(docker ps --filter "label=com.docker.compose.project" --format '{{.Names}}' 2>/dev/null \
  | grep -E "^(plane-|pms-|traefik)" || true)

if [ -n "$RUNNING" ]; then
  err "Vẫn còn container đang chạy:"
  echo "$RUNNING" | sed 's/^/  /'
  err "Hãy chạy './scripts/stop.sh --all' trước khi clean."
  exit 1
fi

# ── build danh sách việc cần làm để hiện confirm ─────────────────────────────
TODO=""
[ "$DO_DATA"    -eq 1 ] && TODO="${TODO}\n  - postgres-data/, redis-data/, rabbitmq_data/"
[ "$DO_UPLOADS" -eq 1 ] && TODO="${TODO}\n  - uploads/"
[ "$DO_CERTS"   -eq 1 ] && TODO="${TODO}\n  - traefik/"
[ "$DO_NETWORK" -eq 1 ] && TODO="${TODO}\n  - Docker network: plane-network"
[ "$DO_IMAGES"  -eq 1 ] && TODO="${TODO}\n  - Docker images: plane-frontend, plane-backend, plane-space, plane-live, plane-admin"

if [ -z "$TODO" ]; then
  info "Không có gì để xóa. Chạy '$0 --help' để xem options."
  exit 0
fi

# ── confirm ───────────────────────────────────────────────────────────────────
warn "Sắp xóa vĩnh viễn:"
printf "$TODO\n"
echo ""

if [ "$YES" -ne 1 ]; then
  printf "Xác nhận? [y/N] "
  read -r REPLY
  case "$REPLY" in
    [yY]|[yY][eE][sS]) ;;
    *) info "Hủy."; exit 0 ;;
  esac
fi

# ── thực thi ──────────────────────────────────────────────────────────────────
if [ "$DO_DATA" -eq 1 ]; then
  info "Xóa data volumes..."
  remove_dir postgres-data
  remove_dir redis-data
  remove_dir rabbitmq_data
fi

if [ "$DO_UPLOADS" -eq 1 ]; then
  info "Xóa uploads..."
  remove_dir uploads
fi

if [ "$DO_CERTS" -eq 1 ]; then
  info "Xóa Traefik certs..."
  remove_dir traefik
fi

if [ "$DO_NETWORK" -eq 1 ]; then
  info "Xóa Docker network plane-network..."
  if docker network inspect plane-network >/dev/null 2>&1; then
    docker network rm plane-network
    ok "Đã xóa network plane-network"
  else
    info "Network plane-network không tồn tại, bỏ qua."
  fi
fi

if [ "$DO_IMAGES" -eq 1 ]; then
  info "Xóa Docker images của Plane..."
  ENV_FILE="${ENV_FILE:-.env}"
  if [ -f "$ENV_FILE" ]; then
    # Đọc danh sách images từ .env
    IMAGES=$(grep -E "^PLANE_.+_IMAGE=" "$ENV_FILE" | cut -d= -f2 | tr -d '"' | tr -d "'")
    IMAGES="$IMAGES rabbitmq:3.13-management-alpine postgres:15-alpine redis:7-alpine traefik:v2.11"
  else
    IMAGES="makeplane/plane-frontend makeplane/plane-backend makeplane/plane-space makeplane/plane-live makeplane/plane-admin"
  fi
  for img in $IMAGES; do
    if docker image inspect "$img" >/dev/null 2>&1; then
      docker rmi "$img" && ok "Đã xóa image: $img"
    else
      info "Image không tồn tại: $img"
    fi
  done
fi

echo ""
ok "Clean hoàn tất."
