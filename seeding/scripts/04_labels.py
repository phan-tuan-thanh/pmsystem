"""
Import labels from data/labels.csv.
Output: id_map/labels_map.json  { external_id -> plane_label_id }
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from common import (
    DATA_DIR, WORKSPACE_SLUG,
    api_post, api_get, load_map, save_map, require_map, log
)

CSV_FILE = DATA_DIR / "labels.csv"


def get_existing_labels(project_id):
    """Return dict of name -> label_id."""
    r = api_get(f"/api/workspaces/{WORKSPACE_SLUG}/projects/{project_id}/labels/")
    if r.status_code != 200:
        return {}
    data = r.json()
    results = data if isinstance(data, list) else data.get("results", [])
    return {lbl["name"]: lbl["id"] for lbl in results}


def main():
    if not CSV_FILE.exists():
        log.error(f"Không tìm thấy {CSV_FILE}")
        sys.exit(1)

    projects_map = require_map("projects")
    labels_map = load_map("labels")
    ok = skip = err = 0

    with open(CSV_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            ext_id = row["external_id"].strip()
            proj_ext = row["project_external_id"].strip()
            name = row["name"].strip()
            color = row.get("color", "#6b7280").strip() or "#6b7280"

            if ext_id in labels_map:
                log.info(f"SKIP   label already mapped: {ext_id}")
                skip += 1
                continue

            project_id = projects_map.get(proj_ext)
            if not project_id:
                log.error(f"ERROR  label {ext_id}: project {proj_ext} not in projects_map")
                err += 1
                continue

            existing = get_existing_labels(project_id)
            if name in existing:
                labels_map[ext_id] = existing[name]
                save_map("labels", labels_map)
                log.info(f"SKIP   label exists: {name} -> {existing[name]}")
                skip += 1
                continue

            payload = {"name": name, "color": color}
            r = api_post(
                f"/api/workspaces/{WORKSPACE_SLUG}/projects/{project_id}/labels/",
                payload,
            )

            if r.status_code in (200, 201):
                label_id = r.json()["id"]
                labels_map[ext_id] = label_id
                save_map("labels", labels_map)
                log.info(f"SUCCESS label created: {ext_id} ({name}) -> {label_id}")
                ok += 1
            else:
                log.error(f"ERROR  label {ext_id}: {r.status_code} {r.text[:200]}")
                err += 1

    save_map("labels", labels_map)
    log.info(f"--- labels: {ok} created, {skip} skipped, {err} errors. Map saved.")


if __name__ == "__main__":
    main()
