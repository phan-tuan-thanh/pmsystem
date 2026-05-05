# Hướng dẫn dành cho Squad Lead trên Plane CE

## 1. Vai trò của bạn
Là **Squad Lead**, bạn là người chịu trách nhiệm cao nhất về hiệu suất và sự phát triển của Squad. Trên Plane CE, bạn không tập trung vào từng task nhỏ mà tập trung vào **Bức tranh tổng thể**, **Quản lý con người** và **Giải quyết các điểm nghẽn cấp độ tổ chức**.

**Câu hỏi chủ đạo:** *"Squad có đang đi đúng lộ trình không? Hiệu suất của team có ổn định không? Có ai cần hỗ trợ phát triển không?"*

---

## 2. Luồng công việc chuẩn (Standard Workflow)

| Giai đoạn | Hành động trên Plane CE | Tần suất |
| :--- | :--- | :--- |
| **Quản trị hệ thống** | Thiết lập Project, phân quyền thành viên trong Squad. | Khi khởi tạo dự án |
| **Giám sát sức khỏe** | Xem biểu đồ Analytics, kiểm tra tốc độ (Velocity) của Squad. | Hàng tuần |
| **Hỗ trợ 1-on-1** | Xem My Issues của từng member để nắm bắt khối lượng công việc. | Trước buổi họp 1-on-1 |
| **Escalate (Leo thang)** | Xử lý các Issue bị block do phụ thuộc vào team khác (Cross-team). | Khi phát sinh |
| **Báo cáo cấp trên** | Xuất báo cáo hoặc chụp Dashboard Analytics cho Tribe Lead/CTO. | Cuối tháng/quý |

---

## 3. Tình huống thực tế (Case Study: Tính năng "Thanh toán Ví MOMO")

### Tình huống 1: Thiết lập dự án ban đầu
Squad của bạn mới bắt đầu dự án E-commerce.
*   **Thao tác:**
    1. Vào **Settings** -> **Members** -> Mời PO, SM, BA, Dev, QA vào dự án.
    2. Thiết lập **Workflows**: Đảm bảo các trạng thái (`In Review`, `Staging`, `UAT`) được cấu hình đúng với quy trình của công ty.
    3. Cấu hình **Estimates**: Chọn hệ thống tính điểm (Fibonacci 1, 2, 3, 5, 8...) để team ước lượng.

### Tình huống 2: Xử lý Block cấp tổ chức
Trong buổi họp, SM báo cáo task "Kết nối MOMO" bị block vì team Hạ tầng chưa mở port firewall.
*   **Thao tác:**
    1. Bạn tìm Issue đó, gắn Label `Urgent` và comment: *"Tôi sẽ làm việc với team Hạ tầng để giải quyết việc này trong chiều nay."*
    2. Sau khi xong, bạn cập nhật thông tin để team biết và tiếp tục làm việc.

---

## 4. Hướng dẫn thao tác chi tiết (Step-by-Step)

### Đọc hiểu Dashboard Analytics (PROD Standard)
1.  **Vào mục Analytics:** Đây là "bảng điều khiển" của bạn.
2.  **Velocity Trend:** Xem team có đang làm việc ổn định không. Nếu đồ thị hình răng cưa quá mạnh, team đang ước lượng không chuẩn hoặc gặp nhiều biến cố.
3.  **Lead Time & Cycle Time:** Đo lường thời gian từ lúc có ý tưởng đến lúc release. Nếu Lead Time quá dài, quy trình phê duyệt hoặc test đang có vấn đề.
4.  **Assignee Distribution:** Kiểm tra xem công việc có đang bị dồn quá nhiều vào một người (Key person) hay không để cân bằng lại.

### Quản lý Member & Quyền hạn
*   Đảm bảo PO có quyền quản lý Backlog, nhưng Developer chỉ nên tập trung vào xử lý Issue.
*   Khi có nhân sự mới, hãy hướng dẫn họ đọc bộ tài liệu này và gán họ vào các Issue "Onboarding" trong Plane.

---

## 5. Phối hợp với các vai trò khác
*   **Với PO:** Thảo luận về nguồn lực nếu PO muốn đẩy thêm quá nhiều tính năng vào một Cycle.
*   **Với SM:** Hỗ trợ SM khi các vấn đề vượt quá tầm kiểm soát của team.
*   **Với Member:** Dùng dữ liệu trên Plane (số task hoàn thành, chất lượng code qua bug rate) để khen ngợi hoặc nhắc nhở một cách khách quan trong các buổi 1-on-1.

---

## 6. Mẹo cho Squad Lead PROD-ready
*   **Custom Dashboard:** Plane cho phép tạo các View riêng. Hãy tạo một View tên là "Squad Overview" lọc tất cả các Issue đang `Blocked` hoặc `High Priority` để bạn có thể kiểm tra trong 5 phút mỗi sáng.
*   **Dẫn dắt bằng dữ liệu:** Thay vì nói "Tôi cảm thấy team đang chậm", hãy nói "Dữ liệu Analytics cho thấy Velocity của chúng ta giảm 20% so với tháng trước, chúng ta cùng tìm nguyên nhân nhé".

---
> [!TIP]
> Plane CE là công cụ giúp bạn giải phóng khỏi việc quản lý vi mô (Micromanagement). Hãy tin tưởng vào dữ liệu và quy trình để tập trung vào việc phát triển con người và chiến lược kỹ thuật.
