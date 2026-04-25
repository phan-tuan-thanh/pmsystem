"""
setup_permissions.py — Cấp quyền admin cho tất cả demo users
"""
from config import APIClient
from seed_users import MEMBERS


def get_demo_user_ids(client: APIClient) -> list:
    emails = {m["email"] for m in MEMBERS}
    rows   = client.list_records("users", page_size=200)
    return [r["id"] for r in rows if r.get("email") in emails]


def assign_admin_role(client: APIClient, user_ids: list) -> None:
    print("\n🔐 Cấp quyền admin cho demo users...\n")
    for uid in user_ids:
        try:
            client.post("/api/rolesUsers:create", {"roleName": "admin", "userId": uid})
            print(f"  ✅ User [{uid}] → admin role")
        except Exception as e:
            print(f"  ⚠️  User [{uid}]: {e}")


def seed(client: APIClient) -> None:
    user_ids = get_demo_user_ids(client)
    print(f"  Tìm thấy {len(user_ids)} demo users.")
    assign_admin_role(client, user_ids)
    print("\n✅ Phân quyền hoàn tất.\n")


if __name__ == "__main__":
    seed(APIClient())
