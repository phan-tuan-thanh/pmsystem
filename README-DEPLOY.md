# 🚀 Plane CE v1.3.0 Deployment Guide (macOS)

Tài liệu này hướng dẫn cách truy cập và quản lý hệ thống Plane CE sau khi đã triển khai thành công bằng Docker.

- xác thực: admin@local.host
- mât khẩu: !3vU9RkREZjqNhX02iiir

## 📍 Thông tin truy cập

Hệ thống sử dụng Traefik làm Reverse Proxy để điều phối các dịch vụ. Do có xung đột cổng mặc định trên Mac, các cổng đã được thay đổi như sau:

* **Tên miền (Domain):** `staging-plane.example.local`
* **HTTPS:** [https://staging-plane.example.local:9443](https://staging-plane.example.local:9443)
* **HTTP:** [http://staging-plane.example.local:90](http://staging-plane.example.local:90)

> [!IMPORTANT]
> Nếu bạn thay đổi cổng HTTPS trong Traefik (ví dụ sang 9443), bạn **BẮT BUỘC** phải cập nhật biến `NEXT_PUBLIC_API_BASE_URL` trong file `.env` bao gồm cả cổng đó (ví dụ: `https://staging-plane.example.local:9443`). Nếu thiếu cổng, trình duyệt sẽ không thể kết nối tới API và gây lỗi vòng lặp (loop).

### Bước 1: Cấu hình file hosts

Nếu chưa thực hiện, hãy chạy lệnh sau để ánh xạ tên miền ảo:

```bash
echo "127.0.0.1 staging-plane.example.local" | sudo tee -a /etc/hosts
```

### Bước 2: Xử lý SSL (Cảnh báo bảo mật)

Vì sử dụng chứng chỉ tự ký tại máy cục bộ, trình duyệt sẽ báo lỗi bảo mật:

1. Nhấn **Advanced** (Nâng cao).
2. Chọn **Proceed to staging-plane.example.local (unsafe)**.

---

## 🛠 Lệnh quản lý hệ thống

Sử dụng các script trong thư mục `scripts/` để vận hành:

| Lệnh                            | Chức năng                               |
| :------------------------------- | :---------------------------------------- |
| `./scripts/check.sh`           | Kiểm tra sức khỏe và xung đột cổng |
| `./scripts/deploy.sh --detach` | Triển khai/Cập nhật toàn bộ stack    |
| `./scripts/stop.sh --all`      | Dừng và gỡ bỏ các container          |
| `docker logs traefik -f`       | Theo dõi log của Proxy (Real-time)      |
| `docker logs plane-api -f`     | Theo dõi log của Backend                |

---

## 🏗 Cấu trúc Stack

Hệ thống bao gồm các thành phần chính:

* **Frontend**: `plane-web` (Cổng 3000 nội bộ)
* **Backend**: `plane-api` (Cổng 8000 nội bộ)
* **Real-time**: `plane-live` (Cổng 3000 nội bộ)
* **Proxy**: `traefik` (Điều phối luồng qua `/api`, `/space`, và root `/`)
* **Database**: `postgres` & `redis`

---

## 📝 Lưu ý quan trọng

1. **Migrator**: Mỗi khi cập nhật phiên bản, dịch vụ `plane-migrator` sẽ tự động chạy để cập nhật cơ sở dữ liệu.
2. **Dung lượng**: Dữ liệu được lưu tại `./postgres-data` và `./uploads`. Hãy backup các thư mục này thường xuyên.
