"""
seed_tasks.py — Tạo ~900 công việc theo kịch bản xác suất (tiếng Việt)
"""
import random
from config import APIClient
from scenarios import pick_status, pick_task_type, pick_priority, pick_story_points

# ── Kho tiêu đề công việc tiếng Việt ─────────────────────────────────────────
STORY_TEMPLATES = [
    "Xây dựng API {feature}",
    "Thiết kế giao diện {feature}",
    "Tích hợp {service} vào hệ thống",
    "Phát triển tính năng {feature}",
    "Cải tiến hiệu năng {module}",
    "Thêm xác thực cho {feature}",
    "Xây dựng luồng {feature} phía người dùng",
    "Triển khai cache cho {module}",
    "Viết unit test cho {module}",
    "Tài liệu hóa API {feature}",
    "Refactor code module {module}",
    "Tối ưu truy vấn {module}",
]

BUG_TEMPLATES = [
    "{module} - Lỗi không tải được dữ liệu",
    "{module} - Nút Submit không hoạt động trên Safari",
    "{module} - Hiển thị sai ngày tháng múi giờ UTC+7",
    "{module} - Session bị hết hạn quá sớm",
    "{module} - File upload quá 10MB bị lỗi 500",
    "{module} - Phân trang không hoạt động đúng",
    "{module} - Lỗi validation không hiển thị thông báo",
    "{module} - API trả về 404 khi ID hợp lệ",
    "{module} - Dữ liệu bị duplicate khi refresh trang",
    "{module} - Không gửi được email thông báo",
    "{module} - Font chữ vỡ trên thiết bị Android",
]

TASK_TEMPLATES = [
    "Cấu hình {env} cho môi trường staging",
    "Viết migration database cho {module}",
    "Thiết lập CI/CD pipeline {feature}",
    "Review code pull request {module}",
    "Cập nhật tài liệu kỹ thuật {module}",
    "Tạo dữ liệu seed cho {module}",
    "Kiểm tra bảo mật {feature}",
    "Cập nhật dependency {module}",
    "Tạo Dockerfile cho {module}",
    "Triển khai {module} lên môi trường UAT",
]

SPIKE_TEMPLATES = [
    "Nghiên cứu giải pháp {topic}",
    "Đánh giá thư viện {topic}",
    "PoC: Tích hợp {topic}",
    "Khảo sát yêu cầu {feature} từ stakeholder",
    "Phân tích rủi ro kỹ thuật {topic}",
    "So sánh các phương án {topic}",
]

FEATURES = [
    "đăng nhập SSO", "đăng ký tài khoản", "quản lý hồ sơ", "thanh toán online",
    "tìm kiếm nâng cao", "xuất báo cáo PDF", "gửi thông báo email", "phê duyệt đa cấp",
    "nhập liệu hàng loạt", "lịch sử thao tác", "quản lý phân quyền", "dashboard thống kê",
    "tích hợp webhook", "API công khai", "xác thực 2 bước", "quản lý kho hàng",
]

MODULES = [
    "Đăng nhập", "Đăng ký", "Trang chủ", "Giỏ hàng", "Thanh toán", "Báo cáo",
    "Quản lý người dùng", "Phân quyền", "Thông báo", "API Gateway", "Database",
    "Giao diện người dùng", "Tích hợp bên thứ ba", "Hiệu năng", "Bảo mật",
    "Upload file", "Tìm kiếm", "Phê duyệt", "Dashboard", "Lịch sử",
]

SERVICES  = ["VNPAY", "Momo", "ZaloPay", "Firebase", "AWS S3", "Google Maps", "SendGrid", "Twilio"]
TOPICS    = ["WebSocket real-time", "GraphQL API", "Event Sourcing", "CQRS pattern",
             "Redis Pub/Sub", "OAuth2 PKCE", "gRPC streaming", "CDC Debezium"]
ENVS      = ["Docker Compose", "Kubernetes", "GitHub Actions", "Jenkins", "Ansible"]

TASKS_PER_SPRINT = {
    "large":  14,
    "medium": 11,
    "small":  9,
}


def _random_title(task_type: str) -> str:
    f = random.choice(FEATURES)
    m = random.choice(MODULES)
    s = random.choice(SERVICES)
    t = random.choice(TOPICS)
    e = random.choice(ENVS)

    if task_type == "bug":
        return random.choice(BUG_TEMPLATES).format(module=m)
    if task_type == "spike":
        return random.choice(SPIKE_TEMPLATES).format(topic=t, feature=f)
    if task_type == "task":
        return random.choice(TASK_TEMPLATES).format(module=m, feature=f, env=e)
    # story
    return random.choice(STORY_TEMPLATES).format(feature=f, module=m, service=s)


def seed(client: APIClient, sprints: list, members: list) -> list:
    print("\n📋 Tạo công việc (tasks)...\n")
    all_tasks = []

    # Lấy dev + QA IDs để assign
    devs = [m for m in members if m["role"] in ("Dev", "QA")]
    all_ids = [m["id"] for m in devs]

    for sprint in sprints:
        sprint_id   = sprint["id"]
        proj_id     = sprint["project_id"]
        scenario    = sprint["scenario"]
        s_status    = sprint["status"]
        size        = sprint["size"]
        member_ids  = sprint.get("member_ids") or all_ids

        n_tasks = TASKS_PER_SPRINT[size]

        # reporter = PO hoặc SM (index 0, 1 trong members)
        reporter_pool = members[:4]  # PO group

        for _ in range(n_tasks):
            task_type = pick_task_type(scenario)
            status, is_spillover, blocked_reason = pick_status(scenario, s_status)
            priority = pick_priority(task_type, scenario)
            points   = pick_story_points(task_type)
            title    = _random_title(task_type)

            assignee_id = random.choice(member_ids) if member_ids else None
            reporter_id = random.choice(reporter_pool)["id"]

            payload = {
                "sprint_id":      sprint_id,
                "project_id":     proj_id,
                "title":          title,
                "task_type":      task_type,
                "status":         status,
                "priority":       priority,
                "story_points":   points,
                "assignee_id":    assignee_id,
                "reporter_id":    reporter_id,
                "is_spillover":   is_spillover,
                "blocked_reason": blocked_reason,
            }

            record  = client.create_record("tasks", payload)
            task_id = record.get("id")
            all_tasks.append({"id": task_id, "status": status, "sprint_id": sprint_id})

        print(f"  ✅ Sprint {sprint['index']+1} / Proj {proj_id} → {n_tasks} tasks")

    total = len(all_tasks)
    done  = sum(1 for t in all_tasks if t["status"] == "completed")
    print(f"\n✅ Đã tạo {total} công việc (Hoàn thành: {done}, Tỉ lệ: {done/total*100:.1f}%).\n")
    return all_tasks


if __name__ == "__main__":
    print("⚠️  Chạy run_all.py để đảm bảo đủ metadata.")
