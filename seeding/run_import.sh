#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# --- check config.env ---
if [ ! -f config.env ]; then
  echo "[ERROR] config.env không tồn tại. Copy từ config.env.example rồi điền thông tin."
  exit 1
fi

# --- check Python deps ---
if ! python3 -c "import requests, dotenv" 2>/dev/null; then
  echo "[INFO] Cài đặt Python dependencies..."
  pip3 install -r requirements.txt -q
fi

echo "========================================"
echo "  Plane CE — Import bắt đầu"
echo "========================================"

STEPS=(
  "scripts/01_users.py"
  "scripts/02_projects.py"
  "scripts/03_members.py"
  "scripts/04_labels.py"
  "scripts/05_issues.py"
  "scripts/06_comments.py"
)

FAILED=0

for step in "${STEPS[@]}"; do
  echo ""
  echo "--- $step ---"
  if python3 "$step"; then
    echo "--- $step: OK"
  else
    echo "--- $step: FAILED (xem logs/)"
    FAILED=$((FAILED + 1))
    # Dừng nếu bước core (users, projects) thất bại — các bước sau sẽ không chạy được
    if [[ "$step" == *"01_"* || "$step" == *"02_"* ]]; then
      echo "[ERROR] Bước core thất bại, dừng import."
      exit 1
    fi
  fi
done

echo ""
echo "========================================"
if [ "$FAILED" -eq 0 ]; then
  echo "  Import hoàn tất — không có lỗi"
else
  echo "  Import hoàn tất — $FAILED bước có lỗi (xem logs/)"
fi
echo "========================================"
echo ""
echo "Log file: logs/$(ls logs/ 2>/dev/null | tail -1)"
