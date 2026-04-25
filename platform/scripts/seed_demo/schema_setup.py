"""
schema_setup.py — Tự động tạo 6 Collections + Fields qua NocoBase REST API
Format đúng với NocoBase v2.x: dùng uiSchema + x-component
"""
from config import APIClient


def _str_field(name, title, required=False):
    return {"name": name, "type": "string", "title": title,
            "required": required,
            "uiSchema": {"type": "string", "title": title, "x-component": "Input"}}

def _text_field(name, title):
    return {"name": name, "type": "text", "title": title,
            "uiSchema": {"type": "string", "title": title, "x-component": "Textarea"}}

def _int_field(name, title):
    return {"name": name, "type": "integer", "title": title,
            "uiSchema": {"type": "number", "title": title, "x-component": "InputNumber"}}

def _float_field(name, title):
    return {"name": name, "type": "float", "title": title,
            "uiSchema": {"type": "number", "title": title, "x-component": "InputNumber",
                         "x-component-props": {"step": 0.01}}}

def _bool_field(name, title):
    return {"name": name, "type": "boolean", "title": title,
            "uiSchema": {"type": "boolean", "title": title, "x-component": "Checkbox"}}

def _date_field(name, title):
    return {"name": name, "type": "dateOnly", "title": title,
            "uiSchema": {"type": "string", "title": title, "x-component": "DatePicker",
                         "x-component-props": {"dateFormat": "DD/MM/YYYY"}}}

def _select_field(name, title, options):
    enum = [{"label": o["label"], "value": o["value"], "color": o.get("color", "default")} for o in options]
    return {"name": name, "type": "string", "title": title,
            "uiSchema": {"type": "string", "title": title, "x-component": "Select", "enum": enum}}


COLLECTIONS = [
    {
        "name": "members",
        "title": "Thành Viên",
        "fields": [
            _str_field("full_name", "Họ Tên", required=True),
            _str_field("email", "Email", required=True),
            _str_field("team", "Nhóm"),
            _select_field("role", "Vai Trò", [
                {"label": "Product Owner",   "value": "PO",  "color": "purple"},
                {"label": "Scrum Master",    "value": "SM",  "color": "blue"},
                {"label": "Lập Trình Viên", "value": "Dev", "color": "green"},
                {"label": "Kiểm Thử Viên",  "value": "QA",  "color": "orange"},
            ]),
            _select_field("seniority", "Cấp Độ", [
                {"label": "Junior", "value": "junior", "color": "gray"},
                {"label": "Mid",    "value": "mid",    "color": "blue"},
                {"label": "Senior", "value": "senior", "color": "gold"},
            ]),
        ],
    },
    {
        "name": "projects",
        "title": "Dự Án",
        "fields": [
            _str_field("name", "Tên Dự Án", required=True),
            _text_field("description", "Mô Tả"),
            _float_field("budget", "Ngân Sách (Triệu VNĐ)"),
            _date_field("start_date", "Ngày Bắt Đầu"),
            _date_field("end_date", "Ngày Kết Thúc"),
            _str_field("tech_stack", "Công Nghệ"),
            _select_field("size", "Quy Mô", [
                {"label": "Lớn",  "value": "large",  "color": "red"},
                {"label": "Vừa",  "value": "medium", "color": "orange"},
                {"label": "Nhỏ",  "value": "small",  "color": "green"},
            ]),
            _select_field("status", "Trạng Thái", [
                {"label": "Lập Kế Hoạch", "value": "planning",  "color": "gray"},
                {"label": "Đang Chạy",    "value": "active",    "color": "blue"},
                {"label": "Hoàn Thành",   "value": "completed", "color": "green"},
                {"label": "Tạm Dừng",     "value": "on_hold",   "color": "orange"},
            ]),
            _select_field("scenario", "Kịch Bản", [
                {"label": "Thành Công",        "value": "happy_path"},
                {"label": "Nhiều Lỗi",         "value": "bug_heavy"},
                {"label": "Chậm Trễ",          "value": "delay"},
                {"label": "Đổi Ưu Tiên",       "value": "priority_shift"},
                {"label": "Quá Tải Nguồn Lực", "value": "resource_overload"},
            ]),
        ],
    },
    {
        "name": "project_members",
        "title": "Thành Viên Dự Án",
        "fields": [
            _int_field("project_id", "Dự Án ID"),
            _int_field("member_id",  "Thành Viên ID"),
            _int_field("allocation", "Tỉ Lệ Tham Gia (%)"),
            _select_field("role_in_project", "Vai Trò Trong Dự Án", [
                {"label": "Product Owner",   "value": "PO"},
                {"label": "Scrum Master",    "value": "SM"},
                {"label": "Lập Trình Viên", "value": "Dev"},
                {"label": "Kiểm Thử Viên",  "value": "QA"},
            ]),
        ],
    },
    {
        "name": "sprints",
        "title": "Sprint",
        "fields": [
            _int_field("project_id", "Dự Án ID"),
            _str_field("name", "Tên Sprint", required=True),
            _text_field("goal", "Mục Tiêu Sprint"),
            _int_field("velocity", "Velocity (Story Points)"),
            _date_field("start_date", "Ngày Bắt Đầu"),
            _date_field("end_date",   "Ngày Kết Thúc"),
            _select_field("status", "Trạng Thái", [
                {"label": "Lập Kế Hoạch", "value": "planning",  "color": "gray"},
                {"label": "Đang Chạy",    "value": "active",    "color": "blue"},
                {"label": "Hoàn Thành",   "value": "completed", "color": "green"},
            ]),
        ],
    },
    {
        "name": "tasks",
        "title": "Công Việc",
        "fields": [
            _int_field("sprint_id",   "Sprint ID"),
            _int_field("project_id",  "Dự Án ID"),
            _int_field("assignee_id", "Người Thực Hiện ID"),
            _int_field("reporter_id", "Người Báo Cáo ID"),
            _str_field("title", "Tiêu Đề", required=True),
            _int_field("story_points", "Story Points"),
            _bool_field("is_spillover",   "Tràn Sprint"),
            _text_field("blocked_reason", "Lý Do Bị Chặn"),
            _select_field("task_type", "Loại", [
                {"label": "User Story",  "value": "story", "color": "blue"},
                {"label": "Lỗi",        "value": "bug",   "color": "red"},
                {"label": "Nhiệm Vụ",   "value": "task",  "color": "gray"},
                {"label": "Nghiên Cứu", "value": "spike", "color": "purple"},
            ]),
            _select_field("status", "Trạng Thái", [
                {"label": "Backlog",      "value": "backlog",     "color": "gray"},
                {"label": "Cần Làm",     "value": "todo",        "color": "blue"},
                {"label": "Đang Làm",    "value": "in_progress", "color": "orange"},
                {"label": "Đang Review", "value": "in_review",   "color": "purple"},
                {"label": "Hoàn Thành",  "value": "completed",   "color": "green"},
                {"label": "Bị Chặn",     "value": "blocked",     "color": "red"},
            ]),
            _select_field("priority", "Độ Ưu Tiên", [
                {"label": "Khẩn Cấp",   "value": "critical", "color": "red"},
                {"label": "Cao",        "value": "high",     "color": "orange"},
                {"label": "Trung Bình", "value": "medium",   "color": "blue"},
                {"label": "Thấp",       "value": "low",      "color": "gray"},
            ]),
        ],
    },
    {
        "name": "task_comments",
        "title": "Bình Luận",
        "fields": [
            _int_field("task_id",   "Công Việc ID"),
            _int_field("member_id", "Thành Viên ID"),
            _text_field("content",  "Nội Dung"),
        ],
    },
]


def collection_exists(client: APIClient, name: str) -> bool:
    try:
        result = client.get(f"/api/collections/{name}")
        return bool(result.get("data"))
    except Exception:
        return False


def create_collection(client: APIClient, col: dict) -> None:
    name = col["name"]
    if collection_exists(client, name):
        print(f"  ⏭  '{name}' đã tồn tại — bỏ qua.")
        return

    client.post("/api/collections", {
        "name": name, "title": col["title"],
        "autoGenId": True, "createdAt": True, "updatedAt": True,
    })
    print(f"  ✅ Collection '{name}' đã tạo.")

    for field in col.get("fields", []):
        try:
            client.post(f"/api/collections/{name}/fields", field)
            print(f"     + {field['name']} ({field['type']})")
        except Exception as e:
            print(f"     ⚠️  {field['name']}: {e}")


def setup(client: APIClient) -> None:
    print("\n📐 Thiết lập Schema...\n")
    for col in COLLECTIONS:
        print(f"→ {col['title']} ({col['name']})")
        create_collection(client, col)
    print("\n✅ Schema hoàn tất.\n")


if __name__ == "__main__":
    setup(APIClient())
