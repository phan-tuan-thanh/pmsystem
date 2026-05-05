# Hướng dẫn dành cho Product Owner (PO) trên Plane CE

## 1. Vai trò của bạn
Là **Product Owner**, mục tiêu cao nhất của bạn trên Plane CE là **Tối đa hóa giá trị sản phẩm**. Bạn là người quyết định "Cái gì đáng làm nhất" và chịu trách nhiệm về nội dung, thứ tự ưu tiên của Product Backlog.

**Câu hỏi chủ đạo:** *"Tính năng nào mang lại giá trị lớn nhất cho khách hàng lúc này?"*

---

## 2. Luồng công việc chuẩn (Standard Workflow)

| Giai đoạn | Hành động trên Plane CE | Tần suất |
| :--- | :--- | :--- |
| **Lập kế hoạch dài hạn** | Tạo Modules và thiết lập lộ trình (Roadmap). | Hàng quý/tháng |
| **Quản lý Backlog** | Tạo Issue mới, viết User Story sơ lược. | Hàng ngày |
| **Ưu tiên (Refinement)** | Sắp xếp thứ tự Issue, gắn Priority (Urgent, High, Medium, Low). | Hàng tuần |
| **Chuẩn bị Sprint** | Phối hợp với BA/SM để chuyển Issue từ Backlog sang trạng thái 'Ready'. | Cuối Sprint cũ |
| **Review** | Kiểm tra kết quả trong Cycle và đóng (Close) các Issue đã hoàn thành. | Cuối Sprint |

---

## 3. Tình huống thực tế (Case Study: Tính năng "Thanh toán Ví MOMO")

### Tình huống 1: Khởi tạo tính năng lớn
Bạn nhận thấy khách hàng cần thanh toán nhanh. Bạn quyết định thêm MOMO vào hệ thống.
*   **Thao tác:** Vào mục **Modules** -> Tạo Module mới tên là "Thanh toán (Payments)".
*   **Mô tả:** Ghi tóm tắt mục tiêu: "Tích hợp các ví điện tử để giảm tỷ lệ bỏ giỏ hàng".

### Tình huống 2: Tạo User Story đầu tiên
*   **Thao tác:** Nhấn nút `C` hoặc click **New Issue**.
*   **Tiêu đề:** "Thanh toán qua ví MOMO".
*   **Properties:**
    *   **Type:** `Feature` hoặc `Task`.
    *   **Priority:** `High` (Vì đây là yêu cầu cấp thiết từ Business).
    *   **Module:** Chọn "Thanh toán".
*   **Content:** Viết theo cấu mẫu: *"Là người mua hàng, tôi muốn thanh toán qua MOMO để giao dịch nhanh chóng và an toàn."*

---

## 4. Hướng dẫn thao tác chi tiết (Step-by-Step)

### Cách quản lý Product Backlog hiệu quả
1.  Vào dự án -> Chọn **Issues** -> Chọn chế độ xem **Spreadsheet** hoặc **Kanban**.
2.  Lọc các Issue ở trạng thái `Backlog`.
3.  Kéo thả để thay đổi thứ tự ưu tiên hoặc thay đổi trực tiếp cột **Priority**.
4.  Sử dụng **Labels** (ví dụ: `v1.0`, `Marketing`, `Hotfix`) để phân loại công việc theo nhóm.

### Theo dõi lộ trình qua Modules
1.  Vào mục **Modules**.
2.  Tại đây bạn có thể thấy tiến độ (%) của từng tính năng lớn dựa trên số lượng Issue đã hoàn thành bên trong.
3.  Nếu Module "Thanh toán" mới đạt 20%, bạn biết rằng cần thúc đẩy team tập trung hơn vào đây.

---

## 5. Chỉ số cần quan tâm (Analytics)
Vào mục **Analytics** và chú ý:
*   **Scope Change:** Theo dõi xem có quá nhiều yêu cầu mới phát sinh giữa chừng làm phình to dự án không.
*   **Issue Health:** Xem có bao nhiêu Issue đang bị "ngâm" quá lâu ở trạng thái chờ.

---

## 6. Mẹo cho PO PROD-ready
*   **Đừng viết quá chi tiết ngay từ đầu:** Hãy để BA giúp bạn làm rõ chi tiết. Bạn chỉ cần tập trung vào **Giá trị (Value)** và **Ưu tiên (Priority)**.
*   **Sử dụng Filters:** Tạo các **Custom Views** (ví dụ: "My High Priority Backlog") và lưu lại để truy cập nhanh hàng ngày.

---
> [!IMPORTANT]
> Bạn là người duy nhất có quyền quyết định Issue nào được làm trước. Hãy kiên định với thứ tự ưu tiên trên Plane CE để team không bị bối rối.
