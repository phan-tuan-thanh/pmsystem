import os
import json
import time
import logging
from datetime import datetime
from pathlib import Path
from dotenv import load_dotenv
import requests

BASE_DIR = Path(__file__).parent.parent
load_dotenv(BASE_DIR / "config.env")

BASE_URL = os.environ["BASE_URL"].rstrip("/")
API_TOKEN = os.environ["API_TOKEN"]
WORKSPACE_SLUG = os.environ["WORKSPACE_SLUG"]
DEFAULT_PASSWORD = os.environ.get("DEFAULT_PASSWORD", "Temp@123456")

ID_MAP_DIR = BASE_DIR / "id_map"
LOG_DIR = BASE_DIR / "logs"
DATA_DIR = BASE_DIR / "data"

ID_MAP_DIR.mkdir(exist_ok=True)
LOG_DIR.mkdir(exist_ok=True)

_run_ts = datetime.now().strftime("%Y%m%d_%H%M%S")
_log_file = LOG_DIR / f"import_{_run_ts}.log"

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-7s  %(message)s",
    handlers=[
        logging.FileHandler(_log_file),
        logging.StreamHandler(),
    ],
)
log = logging.getLogger("import")


def headers():
    return {"Authorization": f"Bearer {API_TOKEN}", "Content-Type": "application/json"}


def api_get(path, params=None):
    url = f"{BASE_URL}{path}"
    for attempt in range(3):
        r = requests.get(url, headers=headers(), params=params, verify=False)
        if r.status_code == 429:
            time.sleep(2 ** attempt)
            continue
        return r
    return r


def api_post(path, payload):
    url = f"{BASE_URL}{path}"
    for attempt in range(3):
        r = requests.post(url, headers=headers(), json=payload, verify=False)
        if r.status_code == 429:
            time.sleep(2 ** attempt)
            continue
        return r
    return r


def load_map(name):
    path = ID_MAP_DIR / f"{name}_map.json"
    if path.exists():
        return json.loads(path.read_text())
    return {}


def save_map(name, data):
    path = ID_MAP_DIR / f"{name}_map.json"
    path.write_text(json.dumps(data, indent=2))


def require_map(name):
    data = load_map(name)
    if not data:
        raise SystemExit(f"[ERROR] id_map/{name}_map.json trống hoặc chưa tồn tại. Chạy bước trước trước.")
    return data
