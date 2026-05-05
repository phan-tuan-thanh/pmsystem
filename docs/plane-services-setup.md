# Plane Services Setup (v1.3.0)

Tài liệu này hướng dẫn cấu hình và triển khai các dịch vụ ứng dụng Plane CE.

## 1. Danh sách Dịch vụ

| Service | Mô tả | Port |
|---------|-------|------|
| `plane-web` | Giao diện React frontend | 3000 |
| `plane-api` | API backend (Django) | 8000 |
| `plane-worker` | Xử lý task nền (Celery) | N/A |
| `plane-space` | Quản lý Spaces | 3000 |
| `plane-live` | Real-time events | N/A |

## 2. Cấu hình Lưu trữ (Storage)

Hệ thống được thiết lập sử dụng **Local Filesystem** thay vì MinIO:
- **Biến môi trường**: `USE_MINIO=0` và `STORAGE_TYPE=local`.
- **Mount Path**: 
  - Host: `./uploads/`
  - Container: `/app/media/`
- **Quyền hạn**: Đảm bảo thư mục `./uploads/` có quyền ghi cho người dùng chạy Docker.

## 3. Biến môi trường quan trọng

- `SECRET_KEY`: Khóa bảo mật cho Django (cần đổi trong production).
- `NEXT_PUBLIC_API_BASE_URL`: URL public của API (phải khớp với domain Traefik).
- `DATABASE_URL`: Chuỗi kết nối Postgres.
- `REDIS_URL`: Chuỗi kết nối Redis.

## 4. Health Checks

- `plane-api`: Tự động kiểm tra tại `/api/health/`.
- `plane-web`: Kiểm tra khả năng render trang chủ.

## 5. Mạng nội bộ

Tất cả các dịch vụ kết nối qua network `plane-net` (external).
