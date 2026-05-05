"""
Import projects from data/projects.csv.
Output: id_map/projects_map.json  { external_id -> plane_project_id }
        id_map/projects_slug_map.json  { external_id -> identifier }
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from common import (
    DATA_DIR, WORKSPACE_SLUG,
    api_post, api_get, load_map, save_map, require_map, log
)

CSV_FILE = DATA_DIR / "projects.csv"


def get_existing_projects():
    """Return dict of identifier -> project_id."""
    existing = {}
    r = api_get(f"/api/workspaces/{WORKSPACE_SLUG}/projects/")
    if r.status_code == 200:
        data = r.json()
        results = data if isinstance(data, list) else data.get("results", [])
        for p in results:
            existing[p["identifier"]] = p["id"]
    return existing


def main():
    if not CSV_FILE.exists():
        log.error(f"Không tìm thấy {CSV_FILE}")
        sys.exit(1)

    users_map = require_map("users")
    existing = get_existing_projects()
    log.info(f"Workspace hiện có {len(existing)} projects.")

    projects_map = load_map("projects")
    ok = skip = err = 0

    with open(CSV_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            ext_id = row["external_id"].strip()
            identifier = row["identifier"].strip().upper()
            owner_email = row["owner_email"].strip()

            if ext_id in projects_map:
                log.info(f"SKIP   project already mapped: {ext_id}")
                skip += 1
                continue

            if identifier in existing:
                projects_map[ext_id] = existing[identifier]
                save_map("projects", projects_map)
                log.info(f"SKIP   project identifier exists: {identifier} -> {existing[identifier]}")
                skip += 1
                continue

            owner_id = users_map.get(owner_email)
            if not owner_id:
                log.error(f"ERROR  project {ext_id}: owner {owner_email} not found in users_map")
                err += 1
                continue

            payload = {
                "name": row["name"].strip(),
                "identifier": identifier,
                "description": row.get("description", "").strip(),
                "network": int(row.get("network", 0) or 0),
            }
            r = api_post(f"/api/workspaces/{WORKSPACE_SLUG}/projects/", payload)

            if r.status_code in (200, 201):
                project_id = r.json()["id"]
                projects_map[ext_id] = project_id
                save_map("projects", projects_map)
                log.info(f"SUCCESS project created: {ext_id} ({identifier}) -> {project_id}")
                ok += 1
            else:
                log.error(f"ERROR  project {ext_id}: {r.status_code} {r.text[:200]}")
                err += 1

    save_map("projects", projects_map)
    log.info(f"--- projects: {ok} created, {skip} skipped, {err} errors. Map saved.")


if __name__ == "__main__":
    main()
