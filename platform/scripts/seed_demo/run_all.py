"""
run_all.py — Entry point: chạy toàn bộ quá trình tạo dữ liệu demo
Lệnh: python run_all.py
      python run_all.py --skip-schema   (nếu đã có schema)
      python run_all.py --reset         (xóa dữ liệu cũ trước khi chạy)
"""
import sys
import time

# Đảm bảo thư mục hiện tại trong PYTHONPATH
import os
sys.path.insert(0, os.path.dirname(__file__))

from config import APIClient

SKIP_SCHEMA = "--skip-schema" in sys.argv
RESET_DATA  = "--reset"       in sys.argv


def reset_collections(client: APIClient) -> None:
    """Xóa toàn bộ records trong 6 collections (không xóa schema)."""
    print("\n🗑  Reset dữ liệu cũ...\n")
    cols = ["task_comments", "tasks", "sprints", "project_members", "projects", "members"]
    for col in cols:
        try:
            # Lấy toàn bộ records rồi xóa
            records = client.list_records(col, page_size=500)
            ids = [r["id"] for r in records if "id" in r]
            if ids:
                client.post(f"/api/{col}:destroy", {"filter": {"id": {"$in": ids}}})
                print(f"  🗑  {col}: đã xóa {len(ids)} records")
            else:
                print(f"  ⏭  {col}: không có dữ liệu")
        except Exception as e:
            print(f"  ⚠️  {col}: lỗi khi reset — {e}")
    print()


def print_banner() -> None:
    print("=" * 60)
    print("  🚀  NocoBase Demo Seed — Agile Project Management")
    print("  📅  Lịch sử: 01/06/2025 → 25/04/2026")
    print("  🇻🇳  Ngôn ngữ: Tiếng Việt")
    print("=" * 60)


def print_summary(members, projects, sprints, tasks) -> None:
    done_tasks = sum(1 for t in tasks if t.get("status") == "completed")
    print("=" * 60)
    print("  ✅  HOÀN TẤT TẠO DỮ LIỆU DEMO")
    print("=" * 60)
    print(f"  👥  Thành viên  : {len(members)}")
    print(f"  📁  Dự án       : {len(projects)}")
    print(f"  🏃  Sprints     : {len(sprints)}")
    print(f"  📋  Công việc   : {len(tasks)}")
    print(f"  ✔   Hoàn thành  : {done_tasks} ({done_tasks/len(tasks)*100:.1f}%)")
    print("=" * 60)
    print()
    print("  🔗  Truy cập NocoBase tại: https://app.local.test")
    print()


def main():
    print_banner()
    t0 = time.time()

    client = APIClient()

    # ── Reset (nếu yêu cầu) ───────────────────────────────────────────────────
    if RESET_DATA:
        reset_collections(client)

    # ── Bước 1: Schema ────────────────────────────────────────────────────────
    if not SKIP_SCHEMA:
        from schema_setup import setup
        setup(client)
    else:
        print("\n⏭  Bỏ qua thiết lập schema (--skip-schema).\n")

    # ── Bước 2: NocoBase System Users ────────────────────────────────────────
    from seed_nocobase_users import seed as seed_nocobase_users
    seed_nocobase_users(client)

    # ── Bước 3: Members collection ────────────────────────────────────────────
    from seed_users import seed as seed_users
    members = seed_users(client)

    # ── Bước 3: Projects + Members ────────────────────────────────────────────
    from seed_projects import seed as seed_projects
    projects = seed_projects(client, members)

    # ── Bước 4: Sprints ───────────────────────────────────────────────────────
    from seed_sprints import seed as seed_sprints
    sprints = seed_sprints(client, projects)

    # ── Bước 5: Tasks ─────────────────────────────────────────────────────────
    from seed_tasks import seed as seed_tasks
    tasks = seed_tasks(client, sprints, members)

    # ── Bước 6: Comments ──────────────────────────────────────────────────────
    from seed_comments import seed as seed_comments
    seed_comments(client, tasks, members)

    # ── Bước 7: Phân quyền ────────────────────────────────────────────────────
    from setup_permissions import seed as setup_perms
    setup_perms(client)

    elapsed = time.time() - t0
    print(f"⏱  Thời gian chạy: {elapsed:.1f}s\n")
    print_summary(members, projects, sprints, tasks)


if __name__ == "__main__":
    main()
