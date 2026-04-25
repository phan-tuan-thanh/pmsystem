"""
config.py — Cấu hình kết nối API và tiện ích chung
"""
import os
import sys
import urllib3
import requests
from datetime import date, timedelta
from dotenv import load_dotenv

# Tắt cảnh báo SSL cho self-signed cert
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Load .env từ thư mục gốc platform/
_ENV_PATH = os.path.join(os.path.dirname(__file__), '..', '..', '.env')
load_dotenv(_ENV_PATH)

# ── Cấu hình ──────────────────────────────────────────────────────────────────
BASE_URL         = "https://app.local.test"
ADMIN_EMAIL      = os.getenv("NOCOBASE_ADMIN_EMAIL", "admin@nocobase.com")
ADMIN_PASSWORD   = os.getenv("NOCOBASE_ADMIN_PASSWORD", "nocobase")

DEMO_START       = date(2025, 6, 1)   # Mốc lịch sử bắt đầu
TODAY            = date(2026, 4, 25)   # Ngày hiện tại giả lập
SPRINT_DAYS      = 14                  # Độ dài mỗi Sprint (ngày)


# ── API Client ─────────────────────────────────────────────────────────────────
class APIClient:
    def __init__(self):
        self.token = self._login()
        self.session = requests.Session()
        self.session.verify = False
        self.session.headers.update({
            "Authorization": f"Bearer {self.token}",
            "Content-Type": "application/json",
        })

    def _login(self) -> str:
        print(f"🔐 Đăng nhập NocoBase ({ADMIN_EMAIL})...")
        resp = requests.post(
            f"{BASE_URL}/api/auth:signIn",
            json={"email": ADMIN_EMAIL, "password": ADMIN_PASSWORD},
            verify=False,
        )
        if resp.status_code != 200:
            print(f"❌ Đăng nhập thất bại: {resp.text}")
            sys.exit(1)
        token = resp.json()["data"]["token"]
        print("✅ Đăng nhập thành công.")
        return token

    def post(self, path: str, data: dict) -> dict:
        resp = self.session.post(f"{BASE_URL}{path}", json=data)
        if not resp.ok:
            print(f"  ⚠️  POST {path} → {resp.status_code}: {resp.text[:200]}")
        resp.raise_for_status()
        return resp.json()

    def get(self, path: str, params: dict = None) -> dict:
        resp = self.session.get(f"{BASE_URL}{path}", params=params)
        resp.raise_for_status()
        return resp.json()

    def delete(self, path: str) -> None:
        resp = self.session.delete(f"{BASE_URL}{path}")
        # 404 được chấp nhận khi xóa thứ không tồn tại
        if resp.status_code not in (200, 204, 404):
            resp.raise_for_status()

    def create_record(self, collection: str, data: dict) -> dict:
        result = self.post(f"/api/{collection}:create", data)
        return result.get("data", result)

    def list_records(self, collection: str, page_size: int = 200) -> list:
        result = self.get(f"/api/{collection}:list", {"pageSize": page_size})
        data = result.get("data", {})
        if isinstance(data, list):
            return data
        return data.get("rows", [])


# ── Tiện ích ngày tháng ────────────────────────────────────────────────────────
def date_str(d: date) -> str:
    return d.strftime("%Y-%m-%d")

def sprint_dates(project_start: date, sprint_index: int):
    """Trả về (start, end) của Sprint thứ sprint_index (0-based)."""
    start = project_start + timedelta(days=sprint_index * SPRINT_DAYS)
    end   = start + timedelta(days=SPRINT_DAYS - 1)
    return start, end

def sprint_status(start: date, end: date) -> str:
    if end < TODAY:
        return "completed"
    if start <= TODAY <= end:
        return "active"
    return "planning"
