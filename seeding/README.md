# Plane CE — Data Seeding / Import

Import hàng loạt users, projects, issues và comments vào Plane CE qua REST API.

---

## Cấu trúc thư mục

```
seeding/
├── README.md               ← tài liệu này
├── config.env.example      ← mẫu cấu hình kết nối
├── requirements.txt        ← Python dependencies
├── run_import.sh           ← orchestrator (chạy tất cả theo thứ tự)
├── data/                   ← file CSV đầu vào (bạn điền dữ liệu vào đây)
│   ├── users.csv
│   ├── projects.csv
│   ├── members.csv
│   ├── labels.csv
│   ├── issues.csv
│   └── comments.csv
├── scripts/                ← script import từng đối tượng
│   ├── common.py           ← helper dùng chung
│   ├── 01_users.py
│   ├── 02_projects.py
│   ├── 03_members.py
│   ├── 04_labels.py
│   ├── 05_issues.py
│   └── 06_comments.py
├── id_map/                 ← tự động tạo khi chạy (mapping external_id → Plane ID)
└── logs/                   ← tự động tạo khi chạy
```

---

## Yêu cầu

- Python 3.8+
- Plane CE đang chạy và có thể reach được từ máy chạy script
- API token của tài khoản **admin** trong workspace

---

## Cài đặt

```sh
cd seeding
pip install -r requirements.txt
cp config.env.example config.env
# Chỉnh sửa config.env với thông tin thực tế
```

---

## Cấu hình (`config.env`)

| Biến | Mô tả | Ví dụ |
|------|-------|-------|
| `BASE_URL` | URL gốc của Plane CE | `https://pms.yourcompany.com` |
| `API_TOKEN` | Bearer token lấy từ Profile → API Tokens | `plane_api_...` |
| `WORKSPACE_SLUG` | Slug của workspace | `my-company` |
| `DEFAULT_PASSWORD` | Mật khẩu tạm cho user mới | `Temp@123456` |

**Lấy API Token:**
1. Đăng nhập Plane CE bằng tài khoản admin
2. Click avatar → **Profile** → **API Tokens**
3. **Create token** → Copy token → Dán vào `config.env`

---

## Chuẩn bị dữ liệu CSV

### `data/users.csv`

| Cột | Bắt buộc | Mô tả |
|-----|----------|-------|
| `email` | ✅ | Email đăng nhập |
| `display_name` | ✅ | Tên hiển thị |
| `first_name` | | Họ |
| `last_name` | | Tên |
| `role` | | `admin` / `member` (mặc định: `member`) |

```csv
email,display_name,first_name,last_name,role
john.doe@company.com,John Doe,John,Doe,member
jane.smith@company.com,Jane Smith,Jane,Smith,admin
dev01@company.com,Dev 01,Dev,01,member
```

---

### `data/projects.csv`

| Cột | Bắt buộc | Mô tả |
|-----|----------|-------|
| `external_id` | ✅ | ID gốc (dùng để tra cứu ở bước sau) |
| `name` | ✅ | Tên project |
| `identifier` | ✅ | Mã viết tắt, 2-12 ký tự IN HOA, không dấu |
| `description` | | Mô tả |
| `network` | | `0`=secret (mặc định), `2`=public |
| `owner_email` | ✅ | Email owner (phải có trong users.csv hoặc đã tồn tại) |

```csv
external_id,name,identifier,description,network,owner_email
PROJ-001,Backend API,BAPI,REST API and microservices,0,john.doe@company.com
PROJ-002,Frontend Web,FWEB,React web application,0,jane.smith@company.com
PROJ-003,Mobile App,MOBI,iOS and Android,0,john.doe@company.com
```

---

### `data/members.csv`

| Cột | Bắt buộc | Mô tả |
|-----|----------|-------|
| `project_external_id` | ✅ | Khớp với `external_id` trong projects.csv |
| `user_email` | ✅ | Email user |
| `role` | ✅ | `10`=viewer, `15`=member, `20`=admin |

```csv
project_external_id,user_email,role
PROJ-001,jane.smith@company.com,20
PROJ-001,dev01@company.com,15
PROJ-002,john.doe@company.com,15
PROJ-002,dev01@company.com,15
PROJ-003,dev01@company.com,20
```

---

### `data/labels.csv`

| Cột | Bắt buộc | Mô tả |
|-----|----------|-------|
| `external_id` | ✅ | ID gốc |
| `project_external_id` | ✅ | Khớp với projects.csv |
| `name` | ✅ | Tên label |
| `color` | | Hex color (mặc định: `#6b7280`) |

```csv
external_id,project_external_id,name,color
LBL-001,PROJ-001,bug,#e11d48
LBL-002,PROJ-001,feature,#2563eb
LBL-003,PROJ-001,improvement,#16a34a
LBL-004,PROJ-002,bug,#e11d48
LBL-005,PROJ-002,ui,#7c3aed
```

---

### `data/issues.csv`

| Cột | Bắt buộc | Mô tả |
|-----|----------|-------|
| `external_id` | ✅ | ID gốc |
| `project_external_id` | ✅ | Khớp với projects.csv |
| `title` | ✅ | Tiêu đề issue |
| `description` | | Nội dung (plain text hoặc Markdown) |
| `state` | | `backlog` / `unstarted` / `started` / `completed` / `cancelled` (mặc định: `backlog`) |
| `priority` | | `none` / `low` / `medium` / `high` / `urgent` (mặc định: `none`) |
| `assignee_email` | | Email người được giao (phải là member của project) |
| `label_external_ids` | | Nhiều label phân cách bằng `;` |
| `due_date` | | `YYYY-MM-DD` |

```csv
external_id,project_external_id,title,description,state,priority,assignee_email,label_external_ids,due_date
ISS-001,PROJ-001,Fix authentication timeout,Token expires too quickly causing logout,started,high,dev01@company.com,LBL-001,2026-06-15
ISS-002,PROJ-001,Add pagination to user list API,Implement cursor-based pagination,backlog,medium,john.doe@company.com,LBL-002,2026-07-01
ISS-003,PROJ-001,Optimize database queries,Slow queries on dashboard endpoint,backlog,high,,LBL-003,
ISS-004,PROJ-002,Fix mobile menu overlap,Menu overlaps content on small screens,unstarted,medium,dev01@company.com,LBL-004;LBL-005,2026-06-20
ISS-005,PROJ-002,Add dark mode toggle,User preference for dark/light theme,backlog,low,jane.smith@company.com,LBL-005,
```

---

### `data/comments.csv`

| Cột | Bắt buộc | Mô tả |
|-----|----------|-------|
| `issue_external_id` | ✅ | Khớp với issues.csv |
| `author_email` | ✅ | Email tác giả |
| `body` | ✅ | Nội dung comment (Markdown) |

```csv
issue_external_id,author_email,body
ISS-001,jane.smith@company.com,Confirmed reproducing on staging. Token TTL is currently 15 minutes.
ISS-001,dev01@company.com,Looking into the JWT config. Will push fix today.
ISS-002,john.doe@company.com,Reference: https://relay.dev/docs/pagination/
ISS-004,dev01@company.com,Reproduced on iPhone SE. Z-index issue with nav component.
```

---

## Chạy import

### Chạy toàn bộ (khuyến nghị)

```sh
cd seeding
chmod +x run_import.sh
./run_import.sh
```

### Chạy từng bước

```sh
cd seeding
python scripts/01_users.py
python scripts/02_projects.py
python scripts/03_members.py
python scripts/04_labels.py
python scripts/05_issues.py
python scripts/06_comments.py
```

### Chạy lại từ bước bị lỗi

Script idempotent — có thể chạy lại an toàn. Các row đã thành công sẽ SKIP.

```sh
python scripts/05_issues.py   # chạy lại chỉ bước issues
```

---

## Đọc kết quả

```sh
# Xem log gần nhất
cat logs/$(ls logs/ | tail -1)

# Đếm kết quả
grep -c "SUCCESS" logs/import_*.log
grep -c "ERROR"   logs/import_*.log
grep -c "SKIP"    logs/import_*.log
```

---

## Thứ tự phụ thuộc

```
users  →  projects  →  members
                    →  labels
                    →  issues  →  comments
```

**Không được đảo thứ tự.** Mỗi bước sinh ra `id_map/` để bước sau tra cứu Plane ID tương ứng.

---

## Lưu ý quan trọng

- **Mật khẩu user:** Plane CE không cho import hash, script đặt `DEFAULT_PASSWORD` từ `config.env`. Yêu cầu user đổi mật khẩu sau lần đăng nhập đầu.
- **`created_at` của issue:** API không cho phép override thời điểm tạo — issue sẽ có timestamp lúc import, không phải lịch sử gốc.
- **State mapping:** Script tự gọi API lấy state IDs thực tế của từng project — không cần điền thủ công.
- **Identifier phải unique** trong workspace. Nếu đã tồn tại, script báo SKIP và vẫn lưu mapping.
