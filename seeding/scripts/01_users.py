"""
Import users from data/users.csv.
Output: id_map/users_map.json  { email -> plane_user_id }
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from common import (
    DATA_DIR, DEFAULT_PASSWORD, WORKSPACE_SLUG,
    api_post, api_get, load_map, save_map, log
)

CSV_FILE = DATA_DIR / "users.csv"


def get_existing_users():
    """Return dict of email -> user_id for users already in the workspace."""
    existing = {}
    page = 1
    while True:
        r = api_get(f"/api/workspaces/{WORKSPACE_SLUG}/members/", params={"page": page})
        if r.status_code != 200:
            break
        data = r.json()
        results = data if isinstance(data, list) else data.get("results", [])
        for m in results:
            member = m.get("member") or m
            email = member.get("email", "")
            uid = member.get("id", "")
            if email and uid:
                existing[email] = uid
        if not results or not (isinstance(data, dict) and data.get("next")):
            break
        page += 1
    return existing


def main():
    if not CSV_FILE.exists():
        log.error(f"Không tìm thấy {CSV_FILE}")
        sys.exit(1)

    existing = get_existing_users()
    log.info(f"Workspace hiện có {len(existing)} members.")

    users_map = load_map("users")
    users_map.update({email: uid for email, uid in existing.items()})

    ok = skip = err = 0

    with open(CSV_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            email = row["email"].strip()
            display_name = row.get("display_name", "").strip() or email
            first_name = row.get("first_name", "").strip()
            last_name = row.get("last_name", "").strip()

            if email in users_map:
                log.info(f"SKIP   user already exists: {email}")
                skip += 1
                continue

            payload = {
                "email": email,
                "password": DEFAULT_PASSWORD,
                "display_name": display_name,
                "first_name": first_name,
                "last_name": last_name,
            }
            r = api_post("/api/auth/sign-up/", payload)

            if r.status_code in (200, 201):
                data = r.json()
                uid = data.get("id") or data.get("user", {}).get("id")
                users_map[email] = uid
                log.info(f"SUCCESS user created: {email} -> {uid}")
                ok += 1
            elif r.status_code == 400 and "email" in r.text.lower():
                # Already exists but not in workspace members — try to find via admin
                log.warning(f"SKIP   sign-up conflict (user may already exist): {email}")
                skip += 1
            else:
                log.error(f"ERROR  user {email}: {r.status_code} {r.text[:200]}")
                err += 1

    save_map("users", users_map)
    log.info(f"--- users: {ok} created, {skip} skipped, {err} errors. Map saved.")


if __name__ == "__main__":
    main()
