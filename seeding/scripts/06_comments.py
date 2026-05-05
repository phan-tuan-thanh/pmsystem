"""
Import comments from data/comments.csv.
Requires: id_map/issues_map.json, id_map/users_map.json
Comments are not deduplicated (no stable external ID) — running twice will create duplicates.
"""
import csv
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from common import (
    DATA_DIR, WORKSPACE_SLUG,
    api_post, require_map, log
)

CSV_FILE = DATA_DIR / "comments.csv"


def main():
    if not CSV_FILE.exists():
        log.error(f"Không tìm thấy {CSV_FILE}")
        sys.exit(1)

    issues_map = require_map("issues")
    users_map = require_map("users")
    ok = skip = err = 0

    with open(CSV_FILE, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            issue_ext = row["issue_external_id"].strip()
            author_email = row["author_email"].strip()
            body = row["body"].strip()

            issue_entry = issues_map.get(issue_ext)
            if not issue_entry:
                log.error(f"ERROR  comment: issue {issue_ext} not in issues_map")
                err += 1
                continue

            issue_id = issue_entry["id"] if isinstance(issue_entry, dict) else issue_entry
            project_id = issue_entry.get("project_id") if isinstance(issue_entry, dict) else None

            if not project_id:
                log.error(f"ERROR  comment: no project_id for issue {issue_ext}")
                err += 1
                continue

            if not body:
                log.warning(f"SKIP   comment for {issue_ext}: empty body")
                skip += 1
                continue

            payload = {"comment_html": f"<p>{body}</p>"}
            r = api_post(
                f"/api/workspaces/{WORKSPACE_SLUG}/projects/{project_id}/issues/{issue_id}/comments/",
                payload,
            )

            if r.status_code in (200, 201):
                log.info(f"SUCCESS comment added to issue {issue_ext} by {author_email}")
                ok += 1
            else:
                log.error(f"ERROR  comment {issue_ext}/{author_email}: {r.status_code} {r.text[:200]}")
                err += 1

    log.info(f"--- comments: {ok} created, {skip} skipped, {err} errors.")


if __name__ == "__main__":
    main()
