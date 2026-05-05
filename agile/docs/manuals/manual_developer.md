# Hướng dẫn dành cho Developer trên Plane CE

## 1. Vai trò của bạn
Là **Developer**, nhiệm vụ của bạn là biến các yêu cầu (User Stories) thành sản phẩm chạy được với chất lượng kỹ thuật cao. Trên Plane CE, bạn sử dụng công cụ để nhận việc, cập nhật tiến độ và phối hợp với các thành viên khác trong team.

**Câu hỏi chủ đạo:** *"Hôm nay tôi cần làm gì? Task này đã đủ thông tin để code chưa?"*

---

## 2. Luồng công việc chuẩn (Standard Workflow)

| Giai đoạn | Hành động trên Plane CE | Tần suất |
| :--- | :--- | :--- |
| **Nhận việc** | Kiểm tra danh sách Issue được gán (Assignee) trong Cycle hiện tại. | Đầu Sprint / Hàng ngày |
| **Cập nhật tiến độ** | Chuyển trạng thái từ `Todo` -> `In Progress` ngay khi bắt đầu code. | Hàng ngày |
| **Ước lượng** | Nhập số điểm ước lượng (**Estimate**) cho task (nếu team có quy định). | Sprint Planning |
| **Hoàn tất code** | Chuyển trạng thái sang `In Review` và tag người review. | Khi xong code |
| **Đóng task** | Chuyển sang `Done` sau khi QA xác nhận. | Cuối Sprint |

---

## 3. Tình huống thực tế (Case Study: Tính năng "Thanh toán Ví MOMO")

### Tình huống 1: Bắt đầu xử lý task
Bạn được gán task "Viết API kết nối MOMO".
*   **Thao tác:** 
    1. Vào mục **My Issues** để thấy task của mình.
    2. Click vào task, đọc kỹ Description và Acceptance Criteria do BA viết.
    3. Chuyển State sang `In Progress`. Việc này giúp SM và PO biết bạn đã bắt đầu làm, tránh hỏi han nhiều.

### Tình huống 2: Gặp khó khăn kỹ thuật
Bạn thấy API của MOMO yêu cầu một tham số mà BA chưa nhắc đến.
*   **Thao tác:** 
    1. Viết Comment trực tiếp vào Issue: *"@BA_Name ơi, tài liệu MOMO yêu cầu thêm tham số `partnerCode`, bạn check lại xem mình lấy ở đâu nhé."*
    2. Nếu bị block hoàn toàn, bạn có thể gắn Label `Blocked` để SM chú ý xử lý.

---

## 4. Hướng dẫn thao tác chi tiết (Step-by-Step)

### Quản lý công việc cá nhân hiệu quả
1.  **Dùng My Issues:** Đây là "bàn làm việc" của riêng bạn. Hãy lọc theo `State: In Progress` để biết mình đang làm dở những gì.
2.  **Cập nhật State:** Đừng bao giờ để task ở `Todo` mà thực tế đã code xong 80%. Hãy cập nhật trạng thái theo thời gian thực.
3.  **Sử dụng Estimates:** Nếu dự án có dùng hệ thống tính điểm (Point), hãy nhập số điểm (1, 2, 3, 5, 8...) vào mục Estimate. Điều này giúp team đo lường được khối lượng công việc bạn đang gánh.

### Liên kết kỹ thuật
*   **Sub-issues:** Nếu task của bạn quá phức tạp, hãy tự tạo các Sub-issues (ví dụ: "Setup database", "Tạo service", "Viết Unit test") để tự quản lý tiến độ cá nhân.
*   **Attachments:** Đính kèm ảnh chụp màn hình kết quả hoặc link đến Pull Request (PR) trong comment để người review dễ theo dõi.

---

## 5. Tương tác với QA
Khi bạn chuyển task sang `In Review` hoặc `Done`:
*   Hãy ghi chú ngắn gọn: *"Đã xong API, đã test local ok. Nhờ @QA_Name verify giúp trên môi trường Staging nhé."*
*   Nếu QA bắt bug, một Issue mới loại Bug sẽ được tạo và link đến task của bạn. Hãy ưu tiên xử lý các bug này để đóng Cycle đúng hạn.

---

## 6. Mẹo cho Developer PROD-ready
*   **Keyboard Shortcuts:** Plane hỗ trợ phím tắt (ví dụ: nhấn `I` để mở nhanh Issues). Hãy tìm hiểu để thao tác nhanh hơn.
*   **Markdown trong Comment:** Dùng block code ` ```javascript ` để dán các đoạn log hoặc mã lỗi khi trao đổi với đồng nghiệp.

---
> [!TIP]
> Plane CE không phải là công cụ để "giám sát" bạn, mà là công cụ để bạn "thể hiện" tiến độ công việc. Một Developer chuyên nghiệp luôn giữ cho danh sách task của mình gọn gàng và minh bạch.
