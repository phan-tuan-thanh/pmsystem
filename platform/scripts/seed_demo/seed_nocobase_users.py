"""
seed_nocobase_users.py — Tạo 30 NocoBase system users (xuất hiện trong Users Manager)
Password mặc định cho tất cả demo users: Demo@2025!
"""
from config import APIClient
from seed_users import MEMBERS

DEFAULT_PASSWORD = "Demo@2025!"


def _username_from_email(email: str) -> str:
    """huong.tran@company.vn → huong.tran"""
    return email.split("@")[0]


def get_existing_emails(client: APIClient) -> set:
    try:
        result = client.get("/api/users:list", {"pageSize": 200})
        data = result.get("data", {})
        rows = data.get("rows", []) if isinstance(data, dict) else []
        return {r.get("email", "") for r in rows}
    except Exception:
        return set()


def seed(client: APIClient) -> list:
    print("\n🔑 Tạo NocoBase system users...\n")

    existing = get_existing_emails(client)
    created  = []
    skipped  = 0

    for m in MEMBERS:
        email = m["email"]

        if email in existing:
            skipped += 1
            print(f"  ⏭  {m['full_name']} ({email}) — đã tồn tại")
            continue

        payload = {
            "nickname": m["full_name"],
            "username": _username_from_email(email),
            "email":    email,
            "password": DEFAULT_PASSWORD,
        }

        try:
            record = client.create_record("users", payload)
            uid = record.get("id")
            created.append({**m, "nocobase_user_id": uid})
            print(f"  ✅ [{uid:3}] {m['full_name']} ({m['role']} / {email})")
        except Exception as e:
            print(f"  ⚠️  {m['full_name']}: {e}")

    print(f"\n✅ Đã tạo {len(created)} users mới. Bỏ qua {skipped} đã tồn tại.")
    print(f"🔑 Password mặc định: {DEFAULT_PASSWORD}\n")
    return created


if __name__ == "__main__":
    client = APIClient()
    seed(client)
