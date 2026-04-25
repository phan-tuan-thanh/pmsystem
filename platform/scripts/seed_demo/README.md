# Hướng Dẫn Tạo Dữ Liệu Demo Agile — NocoBase

> Lưu ý: Đây là tài liệu demo cho NocoBase cũ. Dự án hiện đang chuyển sang Plane CE + AI nên nội dung này chỉ dùng để tham chiếu hoặc chuyển đổi dữ liệu.

## Tổng Quan

Script tự động tạo bộ dữ liệu demo quản lý dự án Agile trực tiếp vào NocoBase qua REST API — không cần thao tác thủ công trên giao diện.

| Hạng mục | Số lượng |
|---|---|
| 🔑 NocoBase system users | 30 |
| 👥 Members (custom collection) | 30 |
| 📁 Dự án (Large/Medium/Small) | 20 |
| 🏃 Sprints | ~85 |
| 📋 Công việc (Tasks) | ~1,000+ |
| 💬 Bình luận | ~500 |
| ⏱ Thời gian chạy | ~20 giây |

---

## Điều Kiện Trước Khi Chạy

> **Yêu cầu bắt buộc:**
> 1. Hệ thống platform đang chạy (`./scripts/check.sh` trả về SUCCESS)
> 2. File `.env` chứa `NOCOBASE_ADMIN_EMAIL` và `NOCOBASE_ADMIN_PASSWORD`
> 3. Python 3.9+ đã cài đặt

---

## Cài Đặt & Chạy

```bash
cd platform/scripts/seed_demo
pip3 install -r requirements.txt

# Chạy lần đầu
python3 run_all.py
```

### Các tùy chọn

| Lệnh | Mô tả |
|---|---|
| `python3 run_all.py` | Chạy đầy đủ (schema + data) |
| `python3 run_all.py --reset` | Xóa data cũ + tạo lại toàn bộ |
| `python3 run_all.py --reset --skip-schema` | Chỉ reset data, giữ schema |

---

## Thông Tin Đăng Nhập

### Tài khoản Admin

| | |
|---|---|
| **URL** | https://app.local.test |
| **Email** | `admin@nocobase.com` |
| **Password** | `nocobase` |

---

### 30 Demo Users (Password chung: `Demo@2025!`)

> **Quyền hạn:** Để thuận tiện cho việc demo và xem dữ liệu ngay lập tức, tất cả 30 users đã được cấp quyền **Admin**.
> **Cách xem dữ liệu:** Sau khi đăng nhập, chọn menu **Settings (bánh răng) → Data Management** ở góc phải trên cùng để xem tất cả các collections (Projects, Tasks, Sprints, v.v.).

#### Product Owners (4 người)

| Họ Tên | Email | Nhóm |
|---|---|---|
| Trần Thị Hương | `huong.tran@company.vn` | Nhóm A |
| Lê Văn Dũng | `dung.le@company.vn` | Nhóm B |
| Phạm Thị Mai | `mai.pham@company.vn` | Nhóm C |
| Nguyễn Văn Khoa | `khoa.nguyen@company.vn` | Nhóm D |

#### Scrum Masters (4 người)

| Họ Tên | Email | Nhóm |
|---|---|---|
| Đỗ Thị Lan | `lan.do@company.vn` | Nhóm A |
| Vũ Đình Nam | `nam.vu@company.vn` | Nhóm B |
| Hoàng Thị Yến | `yen.hoang@company.vn` | Nhóm C |
| Bùi Văn Tú | `tu.bui@company.vn` | Nhóm D |

#### Senior Developers (6 người) — Bottleneck: 3-4 dự án/người

| Họ Tên | Email | Nhóm |
|---|---|---|
| Nguyễn Minh Tuấn | `tuan.nguyen@company.vn` | Nhóm A |
| Trần Văn Hùng | `hung.tran@company.vn` | Nhóm B |
| Lê Thị Thu | `thu.le@company.vn` | Nhóm C |
| Phạm Văn Đức | `duc.pham@company.vn` | Nhóm D |
| Đinh Thị Hoa | `hoa.dinh@company.vn` | Nhóm A |
| Cao Văn Long | `long.cao@company.vn` | Nhóm B |

#### Mid Developers (8 người)

| Họ Tên | Email | Nhóm |
|---|---|---|
| Phan Thị Nga | `nga.phan@company.vn` | Nhóm A |
| Lý Văn Bình | `binh.ly@company.vn` | Nhóm B |
| Tạ Thị Kim | `kim.ta@company.vn` | Nhóm C |
| Đặng Văn Sơn | `son.dang@company.vn` | Nhóm D |
| Huỳnh Thị Cúc | `cuc.huynh@company.vn` | Nhóm A |
| Võ Văn Thắng | `thang.vo@company.vn` | Nhóm B |
| Mai Thị Linh | `linh.mai@company.vn` | Nhóm C |
| Trương Văn Phong | `phong.truong@company.vn` | Nhóm D |

#### Junior Developers (4 người)

| Họ Tên | Email | Nhóm |
|---|---|---|
| Ngô Thị Hạnh | `hanh.ngo@company.vn` | Nhóm A |
| Lưu Văn Kiên | `kien.luu@company.vn` | Nhóm B |
| Quách Thị Thúy | `thuy.quach@company.vn` | Nhóm C |
| Dương Văn Hiếu | `hieu.duong@company.vn` | Nhóm D |

#### QA Engineers (4 người)

| Họ Tên | Email | Nhóm |
|---|---|---|
| Hà Thị Phương | `phuong.ha@company.vn` | Nhóm A |
| Bạch Văn Tài | `tai.bach@company.vn` | Nhóm B |
| Lương Thị Vân | `van.luong@company.vn` | Nhóm C |
| Chu Văn Đạt | `dat.chu@company.vn` | Nhóm D |

---

## Dữ Liệu Được Tạo

### 20 Dự Án (từ 01/06/2025)

| # | Tên Dự Án | Quy Mô | Kịch Bản | Trạng Thái |
|---|---|---|---|---|
| 1 | Hệ Thống ERP Nội Bộ | Lớn | Thành Công | Hoàn Thành |
| 2 | Ứng Dụng Ngân Hàng Di Động | Lớn | Nhiều Lỗi | Đang Chạy |
| 3 | Pipeline Dữ Liệu AI | Lớn | Quá Tải NL | Đang Chạy |
| 4 | Di Chuyển Hạ Tầng Lên Cloud | Lớn | Đổi Ưu Tiên | Tạm Dừng |
| 5 | Tái Cấu Trúc Microservices | Lớn | Chậm Trễ | Đang Chạy |
| 6 | Hệ Thống CRM | Vừa | Thành Công | Hoàn Thành |
| 7 | Nâng Cấp Sàn Thương Mại Điện Tử | Vừa | Nhiều Lỗi | Đang Chạy |
| 8 | Cổng Thông Tin Nhân Sự | Vừa | Chậm Trễ | Đang Chạy |
| 9 | Bảng Báo Cáo Thống Kê | Vừa | Thành Công | Hoàn Thành |
| 10 | API Quản Lý Kho | Vừa | Đổi Ưu Tiên | Đang Chạy |
| 11 | Ứng Dụng Tích Điểm Khách Hàng | Vừa | Quá Tải NL | Tạm Dừng |
| 12 | Dịch Vụ Thông Báo Đa Kênh | Vừa | Thành Công | Hoàn Thành |
| 13 | Cổng Tự Phục Vụ Khách Hàng | Nhỏ | Thành Công | Hoàn Thành |
| 14 | API Gateway Tập Trung | Nhỏ | Nhiều Lỗi | Đang Chạy |
| 15 | Dịch Vụ Xác Thực & Phân Quyền | Nhỏ | Thành Công | Hoàn Thành |
| 16 | Công Cụ Tự Động Hóa DevOps | Nhỏ | Chậm Trễ | Đang Chạy |
| 17 | Công Cụ Xuất Báo Cáo Dữ Liệu | Nhỏ | Đổi Ưu Tiên | Tạm Dừng |
| 18 | Wiki Kiến Thức Nội Bộ | Nhỏ | Thành Công | Hoàn Thành |
| 19 | Hệ Thống Kiểm Thử Tự Động | Nhỏ | Quá Tải NL | Đang Chạy |
| 20 | Nền Tảng Giám Sát Hệ Thống | Nhỏ | Thành Công | Hoàn Thành |

### 5 Kịch Bản Agile

| Kịch Bản | Tỉ lệ Done | Đặc điểm nổi bật |
|---|---|---|
| 🟢 **Thành Công** | ~85% | Velocity tăng đều, ít bug |
| 🔴 **Nhiều Lỗi** | ~62% | 30% task là Bug, 20% Reopen |
| 🟡 **Chậm Trễ** | ~58% | 27% task `is_spillover=true` |
| 🟠 **Đổi Ưu Tiên** | ~68% | 18% Bị Chặn, 12% Spike |
| 🔵 **Quá Tải NL** | ~65% | Senior Dev ở 3-4 dự án, allocation < 100% |

### 6 Collections (Schema)

| Collection | Tên hiển thị | Mô tả |
|---|---|---|
| `members` | Thành Viên | Thông tin thành viên nhóm dự án |
| `projects` | Dự Án | 20 dự án với đầy đủ metadata |
| `project_members` | Thành Viên Dự Án | Quan hệ N:N user ↔ project + allocation |
| `sprints` | Sprint | Các chu kỳ phát triển |
| `tasks` | Công Việc | Công việc với type/status/priority/story points |
| `task_comments` | Bình Luận | Bình luận review và blocker note |

---

## Cấu Trúc Files

```
scripts/seed_demo/
├── run_all.py              ← Entry point — chạy lệnh này
├── config.py               ← Kết nối API, đọc .env, tiện ích ngày
├── schema_setup.py         ← Tạo 6 Collections + Fields tự động
├── scenarios.py            ← Logic 5 kịch bản Agile (xác suất)
├── seed_nocobase_users.py  ← Tạo 30 NocoBase system users (Users Manager)
├── seed_users.py           ← Tạo 30 records trong members collection
├── seed_projects.py        ← Tạo 20 dự án + phân công nhân sự
├── seed_sprints.py         ← Sprints tự tính ngày từ 06/2025
├── seed_tasks.py           ← Công việc theo kịch bản xác suất
├── seed_comments.py        ← Bình luận review/blocker
├── requirements.txt        ← Python dependencies
└── README.md               ← File này
```

---

## Phân Biệt Hai Loại "User"

| | NocoBase System Users | `members` Collection |
|---|---|---|
| **Xem tại** | Settings → Users Manager | Data Management → members |
| **Mục đích** | Đăng nhập vào NocoBase | Assignee/Reporter của tasks |
| **Số lượng** | 30 (+ 1 admin) | 30 |
| **Password** | `Demo@2025!` | N/A |
| **Tạo bởi** | `seed_nocobase_users.py` | `seed_users.py` |

---

## Xử Lý Lỗi Thường Gặp

**Lỗi đăng nhập**
```
❌ Đăng nhập thất bại
```
→ Kiểm tra `NOCOBASE_ADMIN_EMAIL` và `NOCOBASE_ADMIN_PASSWORD` trong `.env`.

**Collection đã tồn tại**
```
⏭ 'members' đã tồn tại — bỏ qua.
```
→ Bình thường, script bỏ qua schema và tiếp tục. Dùng `--reset` nếu muốn xóa data cũ.

**Cảnh báo SSL**
```
NotOpenSSLWarning: urllib3 v2 only supports OpenSSL...
```
→ Không ảnh hưởng, script vẫn chạy bình thường.

**Muốn làm sạch và chạy lại từ đầu**
```bash
python3 run_all.py --reset
```
