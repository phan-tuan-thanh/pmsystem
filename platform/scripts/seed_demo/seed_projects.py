"""
seed_projects.py — Tạo 20 dự án + phân công thành viên (project_members)
"""
import random
from datetime import date
from config import APIClient, date_str

# ── Định nghĩa 20 dự án ───────────────────────────────────────────────────────
PROJECTS_DEF = [
    # Large (5)
    {"name": "Hệ Thống ERP Nội Bộ",               "size": "large",  "scenario": "happy_path",       "status": "completed", "start": date(2025,6,1),  "end": date(2026,2,28), "sprints": 8,  "budget": 2500.0, "tech": "Java, React, PostgreSQL"},
    {"name": "Ứng Dụng Ngân Hàng Di Động",         "size": "large",  "scenario": "bug_heavy",        "status": "active",    "start": date(2025,6,15), "end": None,            "sprints": 6,  "budget": 3000.0, "tech": "Flutter, Node.js, MongoDB"},
    {"name": "Pipeline Dữ Liệu AI",                "size": "large",  "scenario": "resource_overload","status": "active",    "start": date(2025,7,1),  "end": None,            "sprints": 7,  "budget": 4000.0, "tech": "Python, Spark, Kafka, GCP"},
    {"name": "Di Chuyển Hạ Tầng Lên Cloud",        "size": "large",  "scenario": "priority_shift",   "status": "on_hold",   "start": date(2025,6,1),  "end": date(2025,11,30),"sprints": 9,  "budget": 5000.0, "tech": "Terraform, AWS, Docker"},
    {"name": "Tái Cấu Trúc Microservices",          "size": "large",  "scenario": "delay",            "status": "active",    "start": date(2025,8,1),  "end": None,            "sprints": 8,  "budget": 2800.0, "tech": "Go, gRPC, Kubernetes"},
    # Medium (7)
    {"name": "Hệ Thống CRM",                       "size": "medium", "scenario": "happy_path",       "status": "completed", "start": date(2025,6,1),  "end": date(2025,11,30),"sprints": 4,  "budget": 800.0,  "tech": "Django, Vue.js, MySQL"},
    {"name": "Nâng Cấp Sàn Thương Mại Điện Tử",   "size": "medium", "scenario": "bug_heavy",        "status": "active",    "start": date(2025,7,1),  "end": None,            "sprints": 5,  "budget": 1200.0, "tech": "Next.js, FastAPI, Redis"},
    {"name": "Cổng Thông Tin Nhân Sự",             "size": "medium", "scenario": "delay",            "status": "active",    "start": date(2025,6,15), "end": None,            "sprints": 4,  "budget": 600.0,  "tech": "Laravel, Angular, MySQL"},
    {"name": "Bảng Báo Cáo Thống Kê",              "size": "medium", "scenario": "happy_path",       "status": "completed", "start": date(2025,6,1),  "end": date(2025,9,30), "sprints": 3,  "budget": 400.0,  "tech": "React, Python, Elasticsearch"},
    {"name": "API Quản Lý Kho",                    "size": "medium", "scenario": "priority_shift",   "status": "active",    "start": date(2025,8,1),  "end": None,            "sprints": 4,  "budget": 700.0,  "tech": "Spring Boot, PostgreSQL"},
    {"name": "Ứng Dụng Tích Điểm Khách Hàng",     "size": "medium", "scenario": "resource_overload","status": "on_hold",   "start": date(2025,9,1),  "end": None,            "sprints": 5,  "budget": 900.0,  "tech": "React Native, Node.js"},
    {"name": "Dịch Vụ Thông Báo Đa Kênh",          "size": "medium", "scenario": "happy_path",       "status": "completed", "start": date(2025,6,1),  "end": date(2025,8,31), "sprints": 3,  "budget": 350.0,  "tech": "Go, RabbitMQ, Firebase"},
    # Small (8)
    {"name": "Cổng Tự Phục Vụ Khách Hàng",        "size": "small",  "scenario": "happy_path",       "status": "completed", "start": date(2025,6,1),  "end": date(2025,7,31), "sprints": 2,  "budget": 150.0,  "tech": "React, Express.js"},
    {"name": "API Gateway Tập Trung",              "size": "small",  "scenario": "bug_heavy",        "status": "active",    "start": date(2025,7,1),  "end": None,            "sprints": 3,  "budget": 200.0,  "tech": "Kong, Nginx, Lua"},
    {"name": "Dịch Vụ Xác Thực & Phân Quyền",     "size": "small",  "scenario": "happy_path",       "status": "completed", "start": date(2025,6,1),  "end": date(2025,7,31), "sprints": 2,  "budget": 180.0,  "tech": "Keycloak, OAuth2"},
    {"name": "Công Cụ Tự Động Hóa DevOps",         "size": "small",  "scenario": "delay",            "status": "active",    "start": date(2025,9,1),  "end": None,            "sprints": 3,  "budget": 250.0,  "tech": "Jenkins, Ansible, Python"},
    {"name": "Công Cụ Xuất Báo Cáo Dữ Liệu",      "size": "small",  "scenario": "priority_shift",   "status": "on_hold",   "start": date(2025,10,1), "end": None,            "sprints": 2,  "budget": 120.0,  "tech": "Python, Pandas, FastAPI"},
    {"name": "Wiki Kiến Thức Nội Bộ",              "size": "small",  "scenario": "happy_path",       "status": "completed", "start": date(2025,6,1),  "end": date(2025,6,30), "sprints": 2,  "budget": 80.0,   "tech": "Confluence, Markdown"},
    {"name": "Hệ Thống Kiểm Thử Tự Động",          "size": "small",  "scenario": "resource_overload","status": "active",    "start": date(2025,8,1),  "end": None,            "sprints": 3,  "budget": 220.0,  "tech": "Playwright, Pytest, GitHub Actions"},
    {"name": "Nền Tảng Giám Sát Hệ Thống",         "size": "small",  "scenario": "happy_path",       "status": "completed", "start": date(2025,7,1),  "end": date(2025,8,31), "sprints": 2,  "budget": 160.0,  "tech": "Grafana, Prometheus, Loki"},
]

PROJECT_DESCRIPTIONS = {
    "happy_path":       "Dự án triển khai suôn sẻ, đúng tiến độ và ngân sách.",
    "bug_heavy":        "Dự án gặp nhiều vấn đề chất lượng, tỉ lệ lỗi cao cần xử lý liên tục.",
    "delay":            "Dự án bị chậm tiến độ do các task thường xuyên bị tràn sang Sprint sau.",
    "priority_shift":   "Dự án thường xuyên thay đổi ưu tiên theo yêu cầu từ stakeholder.",
    "resource_overload":"Dự án bị ảnh hưởng do các thành viên chủ chốt tham gia quá nhiều dự án cùng lúc.",
}


def _assign_members(project: dict, members: list, proj_idx: int) -> list:
    """
    Xây dựng danh sách thành viên cho 1 dự án.
    - PO (1), SM (1), Dev (2-5), QA (1-2)
    - Senior Dev được chia sẻ giữa nhiều dự án (bottleneck)
    """
    pos       = [m for m in members if m["role"] == "PO"]
    sms       = [m for m in members if m["role"] == "SM"]
    sr_devs   = [m for m in members if m["role"] == "Dev" and m["seniority"] == "senior"]
    mid_devs  = [m for m in members if m["role"] == "Dev" and m["seniority"] == "mid"]
    jr_devs   = [m for m in members if m["role"] == "Dev" and m["seniority"] == "junior"]
    qas       = [m for m in members if m["role"] == "QA"]

    size = project["size"]
    assignments = []

    # PO
    po = pos[proj_idx % len(pos)]
    assignments.append({"member": po, "role_in_project": "PO", "allocation": 50})

    # SM
    sm = sms[proj_idx % len(sms)]
    assignments.append({"member": sm, "role_in_project": "SM", "allocation": 75})

    # Senior Devs (chia sẻ → allocation < 100 ở dự án resource_overload)
    n_sr = {"large": 2, "medium": 1, "small": 1}[size]
    for i in range(n_sr):
        sr = sr_devs[(proj_idx + i) % len(sr_devs)]
        alloc = 75 if project["scenario"] == "resource_overload" else 100
        assignments.append({"member": sr, "role_in_project": "Dev", "allocation": alloc})

    # Mid Devs
    n_mid = {"large": 3, "medium": 2, "small": 1}[size]
    for i in range(n_mid):
        md = mid_devs[(proj_idx * 2 + i) % len(mid_devs)]
        assignments.append({"member": md, "role_in_project": "Dev", "allocation": 100})

    # Junior Devs (chỉ với dự án lớn và một số vừa)
    if size == "large" or (size == "medium" and proj_idx % 2 == 0):
        jr = jr_devs[proj_idx % len(jr_devs)]
        assignments.append({"member": jr, "role_in_project": "Dev", "allocation": 100})

    # QA
    n_qa = {"large": 2, "medium": 1, "small": 1}[size]
    for i in range(n_qa):
        qa = qas[(proj_idx + i) % len(qas)]
        assignments.append({"member": qa, "role_in_project": "QA", "allocation": 75})

    return assignments


def seed(client: APIClient, members: list) -> list:
    print("\n📁 Tạo dự án + phân công thành viên...\n")
    created_projects = []

    for idx, proj_def in enumerate(PROJECTS_DEF):
        # Lọc bỏ các trường None để tránh lỗi 500 từ API
        payload = {k: v for k, v in {
            "name":        proj_def["name"],
            "description": PROJECT_DESCRIPTIONS[proj_def["scenario"]],
            "size":        proj_def["size"],
            "status":      proj_def["status"],
            "scenario":    proj_def["scenario"],
            "budget":      proj_def["budget"],
            "start_date":  date_str(proj_def["start"]),
            "end_date":    date_str(proj_def["end"]) if proj_def["end"] else None,
            "tech_stack":  proj_def["tech"],
        }.items() if v is not None}
        record = client.create_record("projects", payload)
        proj_id = record.get("id")

        proj_data = {**proj_def, "id": proj_id}

        # Phân công thành viên
        assignments = _assign_members(proj_def, members, idx)
        proj_data["member_ids"] = []

        for assign in assignments:
            pm_payload = {
                "project_id":       proj_id,
                "member_id":        assign["member"]["id"],
                "role_in_project":  assign["role_in_project"],
                "allocation":       assign["allocation"],
            }
            client.create_record("project_members", pm_payload)
            proj_data["member_ids"].append(assign["member"]["id"])

        created_projects.append(proj_data)
        print(f"  ✅ [{proj_id:2}] {proj_def['name']} ({proj_def['size']} / {proj_def['scenario']}) — {len(assignments)} thành viên")

    print(f"\n✅ Đã tạo {len(created_projects)} dự án.\n")
    return created_projects


if __name__ == "__main__":
    from seed_users import MEMBERS as _RAW
    client = APIClient()
    # Khi chạy độc lập, cần lấy ID từ API
    existing = client.list_records("members", page_size=50)
    seed(client, existing)
