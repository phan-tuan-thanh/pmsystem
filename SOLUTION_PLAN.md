# Giải pháp chuyển đổi từ NocoBase sang Plane CE + AI

## Vấn đề hiện tại

- NocoBase hiện có giao diện business platform nhưng không hỗ trợ tốt các yêu cầu agile.
- Dự án cần một nền tảng self-hosted linh hoạt hơn, dễ mở rộng và tích hợp AI hỗ trợ.

## Quyết định đề xuất

- Bỏ NocoBase và chuyển sang dùng `Plane CE` làm nền tảng chính.
- Bổ sung một service AI để hỗ trợ:
  - tự động tạo task/giao diện backlog
  - đề xuất sprint, story point, priority
  - tự động phân công và nhận xét tiến độ
- Giữ lại hạ tầng chung hiện có:
  - `Traefik` làm reverse proxy + HTTPS
  - `Authentik` làm SSO / Identity Provider
  - `Postgres` làm database chung
  - `Redis` làm cache/queue nếu cần

## Mục tiêu kiến trúc

- Mỗi ứng dụng có `docker-compose.yml` riêng.
- Cấu hình chung quản lý bằng `compose.shared.yml` và `.env` trung tâm.
- Thêm module `plane-ce/` thay cho `nocobase/`.
- Thêm service AI riêng nếu cần (ví dụ `ai-assistant/` hoặc `plane-ai/`).
- Triển khai theo kiểu self-hosted, dễ backup và dễ nâng cấp.

## Phạm vi thay đổi

1. Thay đổi tài liệu và cấu trúc để phản ánh Plane CE.
2. Thay thế `platform/nocobase/` bằng `platform/plane-ce/` trong cấu trúc triển khai.
3. Định nghĩa service AI tích hợp (hoặc API kết nối đến LLM).
4. Xây dựng mô hình dữ liệu Agile trên Plane CE:
   - Project
   - Epic/Feature
   - Sprint
   - Backlog / Task
   - Issue / Bug
   - Report/Burndown
5. Lập kế hoạch di chuyển dữ liệu nếu cần từ NocoBase sang Plane CE.

## Các bước tiếp theo

1. Chuẩn hóa tài liệu hiện tại (đã thực hiện).
2. Thiết kế `docker-compose` cho `plane-ce`.
3. Thiết kế `docker-compose` cho service AI hoặc tích hợp API.
4. Viết kịch bản migration/seed dữ liệu mới.
5. Kiểm thử triển khai trên môi trường dev/local trước khi rollout.

## Ghi chú

- Giữ lại tài liệu `platform/scripts/seed_demo/README.md` như tài liệu tham chiếu NocoBase hiện tại nếu cần so sánh.
- Sau khi quyết định xong, có thể xóa hoặc archive phần `nocobase/` cũ.
