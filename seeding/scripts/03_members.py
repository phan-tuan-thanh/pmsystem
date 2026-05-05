"""
Add members to projects from data/members.csv.
Requires: id_map/users_map.json, id_map/projects_map.json
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from common import (
    DATA_DIR, WORKSPACE_SLUG,
    api_post, api_get, require_map, log
)

CSV_FILE = DATA_DIR / "members.csv"

ROLE_LABELS = {"10": "viewer", "15": "member", "20": "admin"}


def get_existing_members(project_id):
    """Return set of user_ids already in the project."""
    r = api_get(f"/api/workspaces/{WORKSPACE_SLUG}/projects/{project_id}/members/")
    if r.status_code != 200:
        return set()
    data = r.json()
    results = data if isinstance(data, list) else data.get("results", [])
    return {m.get("member", {}).get("id") or m.get("id") for m in results}


def main():
    if not CSV_FILE.exists():
        log.error(f"Không tìm thấy {CSV_FILE}")
        sys.exit(1)

    users_map = require_map("users")
    projects_map = require_map("projects")

    ok = skip = err = 0

    with open(CSV_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            proj_ext = row["project_external_id"].strip()
            email = row["user_email"].strip()
            role = str(row.get("role", "15")).strip()

            project_id = projects_map.get(proj_ext)
            if not project_id:
                log.error(f"ERROR  members: project {proj_ext} not in projects_map")
                err += 1
                continue

            user_id = users_map.get(email)
            if not user_id:
                log.error(f"ERROR  members: user {email} not in users_map")
                err += 1
                continue

            existing = get_existing_members(project_id)
            if user_id in existing:
                log.info(f"SKIP   {email} already member of {proj_ext}")
                skip += 1
                continue

            payload = {"members": [{"member_id": user_id, "role": int(role)}]}
            r = api_post(
                f"/api/workspaces/{WORKSPACE_SLUG}/projects/{project_id}/members/",
                payload,
            )

            if r.status_code in (200, 201):
                log.info(f"SUCCESS member added: {email} -> {proj_ext} (role={ROLE_LABELS.get(role, role)})")
                ok += 1
            else:
                log.error(f"ERROR  member {email}/{proj_ext}: {r.status_code} {r.text[:200]}")
                err += 1

    log.info(f"--- members: {ok} added, {skip} skipped, {err} errors.")


if __name__ == "__main__":
    main()
