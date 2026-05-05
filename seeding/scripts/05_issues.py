"""
Import issues from data/issues.csv.
Output: id_map/issues_map.json  { external_id -> plane_issue_id }

State mapping: fetches real state IDs from each project automatically.
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from common import (
    DATA_DIR, WORKSPACE_SLUG,
    api_post, api_get, load_map, save_map, require_map, log
)

CSV_FILE = DATA_DIR / "issues.csv"

STATE_GROUP_MAP = {
    "backlog": "backlog",
    "unstarted": "unstarted",
    "started": "started",
    "completed": "completed",
    "cancelled": "cancelled",
}

_state_cache = {}


def get_states(project_id):
    """Return dict of group_name -> state_id (first state in that group)."""
    if project_id in _state_cache:
        return _state_cache[project_id]
    r = api_get(f"/api/workspaces/{WORKSPACE_SLUG}/projects/{project_id}/states/")
    mapping = {}
    if r.status_code == 200:
        data = r.json()
        results = data if isinstance(data, list) else data.get("results", [])
        for s in results:
            group = s.get("group", "")
            if group and group not in mapping:
                mapping[group] = s["id"]
    _state_cache[project_id] = mapping
    return mapping


def main():
    if not CSV_FILE.exists():
        log.error(f"Không tìm thấy {CSV_FILE}")
        sys.exit(1)

    projects_map = require_map("projects")
    users_map = require_map("users")
    labels_map = require_map("labels")
    issues_map = load_map("issues")
    ok = skip = err = 0

    with open(CSV_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            ext_id = row["external_id"].strip()
            proj_ext = row["project_external_id"].strip()

            if ext_id in issues_map:
                log.info(f"SKIP   issue already mapped: {ext_id}")
                skip += 1
                continue

            project_id = projects_map.get(proj_ext)
            if not project_id:
                log.error(f"ERROR  issue {ext_id}: project {proj_ext} not in projects_map")
                err += 1
                continue

            states = get_states(project_id)
            state_key = STATE_GROUP_MAP.get(row.get("state", "backlog").strip(), "backlog")
            state_id = states.get(state_key) or states.get("backlog")

            assignee_email = row.get("assignee_email", "").strip()
            assignee_id = users_map.get(assignee_email) if assignee_email else None

            raw_labels = row.get("label_external_ids", "").strip()
            label_ids = []
            if raw_labels:
                for lext in raw_labels.split(";"):
                    lid = labels_map.get(lext.strip())
                    if lid:
                        label_ids.append(lid)
                    else:
                        log.warning(f"WARN   issue {ext_id}: label {lext.strip()} not in labels_map, skipping")

            due_date = row.get("due_date", "").strip() or None

            payload = {
                "name": row["title"].strip(),
                "description_html": f"<p>{row.get('description', '').strip()}</p>",
                "priority": row.get("priority", "none").strip() or "none",
                "state": state_id,
                "label_ids": label_ids,
            }
            if assignee_id:
                payload["assignees"] = [assignee_id]
            if due_date:
                payload["due_date"] = due_date

            r = api_post(
                f"/api/workspaces/{WORKSPACE_SLUG}/projects/{project_id}/issues/",
                payload,
            )

            if r.status_code in (200, 201):
                issue_id = r.json()["id"]
                issues_map[ext_id] = {"id": issue_id, "project_id": project_id}
                save_map("issues", issues_map)
                log.info(f"SUCCESS issue created: {ext_id} -> {issue_id}")
                ok += 1
            else:
                log.error(f"ERROR  issue {ext_id}: {r.status_code} {r.text[:200]}")
                err += 1

    save_map("issues", issues_map)
    log.info(f"--- issues: {ok} created, {skip} skipped, {err} errors. Map saved.")


if __name__ == "__main__":
    main()
