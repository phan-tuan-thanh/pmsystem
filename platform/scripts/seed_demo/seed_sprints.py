"""
seed_sprints.py — Tạo Sprints cho từng dự án (tính ngày tự động từ 06/2025)
"""
import random
from config import APIClient, date_str, sprint_dates, sprint_status

SPRINT_GOALS = {
    "large": [
        "Xây dựng kiến trúc hệ thống và thiết lập môi trường CI/CD",
        "Hoàn thiện module xác thực và phân quyền người dùng",
        "Phát triển API lõi và tích hợp cơ sở dữ liệu",
        "Xây dựng giao diện người dùng cho module chính",
        "Tích hợp dịch vụ bên thứ ba và hệ thống thanh toán",
        "Kiểm thử hiệu năng và tối ưu hóa truy vấn",
        "Hoàn thiện tính năng báo cáo và xuất dữ liệu",
        "Kiểm thử UAT và chuẩn bị triển khai production",
        "Khắc phục lỗi sau go-live và tối ưu hóa hệ thống",
    ],
    "medium": [
        "Khởi động dự án và thiết lập nền tảng kỹ thuật",
        "Phát triển tính năng cốt lõi theo yêu cầu ưu tiên cao",
        "Hoàn thiện giao diện và tích hợp với hệ thống hiện có",
        "Kiểm thử toàn diện và sửa lỗi trước khi phát hành",
        "Triển khai và theo dõi sau khi ra mắt",
    ],
    "small": [
        "Thiết lập dự án và phát triển tính năng chính",
        "Kiểm thử, sửa lỗi và hoàn thiện sản phẩm",
        "Triển khai production và bàn giao tài liệu",
    ],
}


def seed(client: APIClient, projects: list) -> list:
    print("\n🏃 Tạo Sprints...\n")
    all_sprints = []

    for proj in projects:
        proj_id     = proj["id"]
        proj_start  = proj["start"]
        n_sprints   = proj["sprints"]
        size        = proj["size"]
        goals       = SPRINT_GOALS[size]

        for i in range(n_sprints):
            s_start, s_end = sprint_dates(proj_start, i)
            s_status       = sprint_status(s_start, s_end)

            # Velocity: chỉ có ý nghĩa khi sprint đã completed
            from scenarios import calc_velocity
            velocity = calc_velocity(i, n_sprints, proj["scenario"]) if s_status == "completed" else 0

            goal = goals[i % len(goals)]

            payload = {
                "project_id": proj_id,
                "name":       f"Sprint {i + 1}",
                "goal":       goal,
                "status":     s_status,
                "start_date": date_str(s_start),
                "end_date":   date_str(s_end),
                "velocity":   velocity,
            }
            record   = client.create_record("sprints", payload)
            sprint_id = record.get("id")

            sprint_data = {
                "id":         sprint_id,
                "project_id": proj_id,
                "index":      i,
                "status":     s_status,
                "start":      s_start,
                "end":        s_end,
                "scenario":   proj["scenario"],
                "size":       size,
                "member_ids": proj.get("member_ids", []),
            }
            all_sprints.append(sprint_data)

        print(f"  ✅ {proj['name']} → {n_sprints} sprints")

    print(f"\n✅ Đã tạo {len(all_sprints)} sprints.\n")
    return all_sprints


if __name__ == "__main__":
    client = APIClient()
    projects = client.list_records("projects", page_size=30)
    # standalone run cần project metadata đầy đủ — dùng run_all.py để đảm bảo
    print("⚠️  Chạy run_all.py để đảm bảo đủ metadata dự án.")
