"""
seed_users.py — Tạo 30 thành viên nhóm (tiếng Việt)
"""
from config import APIClient

MEMBERS = [
    # Product Owners (4) — tham gia 2-4 dự án
    {"full_name": "Trần Thị Hương",  "email": "huong.tran@company.vn",   "role": "PO",  "seniority": "senior", "team": "Nhóm A"},
    {"full_name": "Lê Văn Dũng",     "email": "dung.le@company.vn",      "role": "PO",  "seniority": "senior", "team": "Nhóm B"},
    {"full_name": "Phạm Thị Mai",    "email": "mai.pham@company.vn",     "role": "PO",  "seniority": "senior", "team": "Nhóm C"},
    {"full_name": "Nguyễn Văn Khoa", "email": "khoa.nguyen@company.vn",  "role": "PO",  "seniority": "senior", "team": "Nhóm D"},
    # Scrum Masters (4) — tham gia 2-3 dự án
    {"full_name": "Đỗ Thị Lan",      "email": "lan.do@company.vn",       "role": "SM",  "seniority": "senior", "team": "Nhóm A"},
    {"full_name": "Vũ Đình Nam",     "email": "nam.vu@company.vn",       "role": "SM",  "seniority": "mid",    "team": "Nhóm B"},
    {"full_name": "Hoàng Thị Yến",   "email": "yen.hoang@company.vn",    "role": "SM",  "seniority": "senior", "team": "Nhóm C"},
    {"full_name": "Bùi Văn Tú",      "email": "tu.bui@company.vn",       "role": "SM",  "seniority": "mid",    "team": "Nhóm D"},
    # Senior Devs (6) — bottleneck: tham gia 3-4 dự án
    {"full_name": "Nguyễn Minh Tuấn","email": "tuan.nguyen@company.vn",  "role": "Dev", "seniority": "senior", "team": "Nhóm A"},
    {"full_name": "Trần Văn Hùng",   "email": "hung.tran@company.vn",    "role": "Dev", "seniority": "senior", "team": "Nhóm B"},
    {"full_name": "Lê Thị Thu",      "email": "thu.le@company.vn",       "role": "Dev", "seniority": "senior", "team": "Nhóm C"},
    {"full_name": "Phạm Văn Đức",    "email": "duc.pham@company.vn",     "role": "Dev", "seniority": "senior", "team": "Nhóm D"},
    {"full_name": "Đinh Thị Hoa",    "email": "hoa.dinh@company.vn",     "role": "Dev", "seniority": "senior", "team": "Nhóm A"},
    {"full_name": "Cao Văn Long",    "email": "long.cao@company.vn",     "role": "Dev", "seniority": "senior", "team": "Nhóm B"},
    # Mid Devs (8) — tham gia 1-2 dự án
    {"full_name": "Phan Thị Nga",    "email": "nga.phan@company.vn",     "role": "Dev", "seniority": "mid",    "team": "Nhóm A"},
    {"full_name": "Lý Văn Bình",     "email": "binh.ly@company.vn",      "role": "Dev", "seniority": "mid",    "team": "Nhóm B"},
    {"full_name": "Tạ Thị Kim",      "email": "kim.ta@company.vn",       "role": "Dev", "seniority": "mid",    "team": "Nhóm C"},
    {"full_name": "Đặng Văn Sơn",    "email": "son.dang@company.vn",     "role": "Dev", "seniority": "mid",    "team": "Nhóm D"},
    {"full_name": "Huỳnh Thị Cúc",  "email": "cuc.huynh@company.vn",   "role": "Dev", "seniority": "mid",    "team": "Nhóm A"},
    {"full_name": "Võ Văn Thắng",    "email": "thang.vo@company.vn",     "role": "Dev", "seniority": "mid",    "team": "Nhóm B"},
    {"full_name": "Mai Thị Linh",    "email": "linh.mai@company.vn",     "role": "Dev", "seniority": "mid",    "team": "Nhóm C"},
    {"full_name": "Trương Văn Phong","email": "phong.truong@company.vn", "role": "Dev", "seniority": "mid",    "team": "Nhóm D"},
    # Junior Devs (4) — tham gia 1 dự án
    {"full_name": "Ngô Thị Hạnh",   "email": "hanh.ngo@company.vn",     "role": "Dev", "seniority": "junior", "team": "Nhóm A"},
    {"full_name": "Lưu Văn Kiên",    "email": "kien.luu@company.vn",     "role": "Dev", "seniority": "junior", "team": "Nhóm B"},
    {"full_name": "Quách Thị Thúy",  "email": "thuy.quach@company.vn",   "role": "Dev", "seniority": "junior", "team": "Nhóm C"},
    {"full_name": "Dương Văn Hiếu",  "email": "hieu.duong@company.vn",   "role": "Dev", "seniority": "junior", "team": "Nhóm D"},
    # QA Engineers (4) — tham gia 2-3 dự án
    {"full_name": "Hà Thị Phương",   "email": "phuong.ha@company.vn",    "role": "QA",  "seniority": "senior", "team": "Nhóm A"},
    {"full_name": "Bạch Văn Tài",    "email": "tai.bach@company.vn",     "role": "QA",  "seniority": "mid",    "team": "Nhóm B"},
    {"full_name": "Lương Thị Vân",   "email": "van.luong@company.vn",    "role": "QA",  "seniority": "mid",    "team": "Nhóm C"},
    {"full_name": "Chu Văn Đạt",     "email": "dat.chu@company.vn",      "role": "QA",  "seniority": "junior", "team": "Nhóm D"},
]


def seed(client: APIClient) -> list:
    """Tạo 30 thành viên. Trả về list dict có thêm trường 'id'."""
    print("\n👥 Tạo danh sách thành viên...\n")
    created = []
    for m in MEMBERS:
        record = client.create_record("members", m)
        member_id = record.get("id")
        m_with_id = {**m, "id": member_id}
        created.append(m_with_id)
        print(f"  ✅ [{member_id:3}] {m['full_name']} ({m['role']} - {m['seniority']})")
    print(f"\n✅ Đã tạo {len(created)} thành viên.\n")
    return created


if __name__ == "__main__":
    client = APIClient()
    seed(client)
