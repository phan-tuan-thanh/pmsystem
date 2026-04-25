"""
seed_comments.py — Tạo ~300 bình luận review/blocker cho các công việc
"""
import random
from config import APIClient

REVIEW_COMMENTS = [
    "Code trông ổn, nhưng cần thêm unit test cho edge case null input.",
    "Đã review, logic đúng. Cần refactor biến đặt tên chưa rõ nghĩa.",
    "Approved! Nhớ cập nhật tài liệu API trước khi merge.",
    "Lỗi nhỏ ở dòng 47 — cần kiểm tra điều kiện boundary.",
    "LGTM. Hãy squash commit trước khi merge vào main.",
    "Chức năng hoạt động tốt, nhưng cần tối ưu truy vấn N+1.",
    "Đã test trên môi trường staging, pass hết. Sẵn sàng merge.",
    "Cần thêm error handling cho trường hợp API timeout.",
    "Style code chưa đồng nhất với convention của dự án, cần sửa.",
    "Performance test cho thấy response time > 2s — cần tối ưu.",
]

BLOCKER_COMMENTS = [
    "Task này đang bị block do chờ xác nhận thiết kế từ PO.",
    "Cần cập nhật schema database trước khi tiếp tục, đang chờ DBA approve.",
    "Đang chờ API từ nhóm backend của team B hoàn thiện.",
    "Môi trường staging đang bị lỗi infrastructure, DevOps đang xử lý.",
    "Yêu cầu thay đổi giữa chừng từ stakeholder, cần họp clarify.",
    "Phụ thuộc vào task #PREV chưa hoàn thành, cần unblock trước.",
    "Đang chờ bằng chứng giải phóng license từ bộ phận pháp lý.",
    "Server staging hết dung lượng, đang chờ được mở rộng.",
]

QA_COMMENTS = [
    "Đã test case TC-01 đến TC-15, pass hết. Đang chạy regression.",
    "Phát hiện lỗi mới khi test trên iOS 17 — mở bug report mới.",
    "Test xong tính năng chính. Còn thiếu test case cho edge case.",
    "Lỗi đã được fix, retest pass. Đóng bug này.",
    "Performance test: Load 1000 users đồng thời — response time 1.2s. OK.",
    "Cross-browser test hoàn thành: Chrome ✓, Firefox ✓, Safari ✗ — cần fix.",
    "Đã test tích hợp với hệ thống thanh toán sandbox, kết quả thành công.",
    "Security scan không phát hiện lỗ hổng nghiêm trọng.",
]

GENERAL_COMMENTS = [
    "Cập nhật tiến độ: đã hoàn thành 70% yêu cầu.",
    "Đã trao đổi với PO, scope được thu hẹp lại.",
    "Tham khảo tài liệu kỹ thuật tại Confluence — link đính kèm.",
    "Hỏi team infra về cấu hình nginx trước khi deploy.",
    "Daily meeting hôm nay: task này sẽ done cuối ngày.",
    "Cần thêm 1 ngày để hoàn thiện phần validation.",
    "Đã thảo luận với SM, task này sẽ ưu tiên trong Sprint này.",
    "Đồng ý với cách tiếp cận. Proceed!",
]

ALL_COMMENT_POOLS = {
    "in_review":   REVIEW_COMMENTS,
    "blocked":     BLOCKER_COMMENTS,
    "completed":   QA_COMMENTS + GENERAL_COMMENTS,
    "in_progress": GENERAL_COMMENTS,
    "backlog":     GENERAL_COMMENTS,
    "todo":        GENERAL_COMMENTS,
}


def seed(client: APIClient, tasks: list, members: list) -> None:
    print("\n💬 Tạo bình luận...\n")

    # Chỉ tạo comment cho ~30% tasks (không tạo hết để tránh dữ liệu thừa)
    sample_tasks = random.sample(tasks, k=min(len(tasks), int(len(tasks) * 0.33)))
    member_ids   = [m["id"] for m in members]
    count        = 0

    for task in sample_tasks:
        task_id    = task["id"]
        task_status= task.get("status", "in_progress")
        pool       = ALL_COMMENT_POOLS.get(task_status, GENERAL_COMMENTS)
        n_comments = random.choices([1, 2, 3], weights=[0.6, 0.3, 0.1])[0]

        for _ in range(n_comments):
            payload = {
                "task_id":   task_id,
                "member_id": random.choice(member_ids),
                "content":   random.choice(pool),
            }
            client.create_record("task_comments", payload)
            count += 1

    print(f"✅ Đã tạo {count} bình luận cho {len(sample_tasks)} công việc.\n")


if __name__ == "__main__":
    print("⚠️  Chạy run_all.py để đảm bảo đủ metadata.")
