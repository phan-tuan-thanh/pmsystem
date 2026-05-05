# Hướng dẫn dành cho QA Engineer trên Plane CE

## 1. Vai trò của bạn
Là **QA Engineer**, bạn là người gác cổng chất lượng. Nhiệm vụ của bạn trên Plane CE là đảm bảo mọi tính năng được xuất xưởng đều đáng tin cậy, hoạt động đúng yêu cầu và không có lỗi nghiêm trọng.

**Câu hỏi chủ đạo:** *"Tính năng này đã pass hết các Acceptance Criteria chưa? Có lỗi tiềm ẩn nào không?"*

---

## 2. Luồng công việc chuẩn (Standard Workflow)

| Giai đoạn | Hành động trên Plane CE | Tần suất |
| :--- | :--- | :--- |
| **Chuẩn bị kịch bản** | Viết Checklist kiểm thử trong **Pages** hoặc trực tiếp trong Issue. | Trước khi Dev xong code |
| **Kiểm thử (Verify)** | Kiểm tra các Issue ở trạng thái `In Review` hoặc `Done`. | Hàng ngày |
| **Báo lỗi (Bugging)** | Tạo mới Issue loại **Bug** khi phát hiện sai sót. | Ngay khi thấy lỗi |
| **Tái kiểm (Re-test)** | Kiểm tra lại các Bug đã được Dev sửa. | Hàng ngày |
| **Xác nhận (Sign-off)** | Chốt trạng thái cuối cùng cho các Issue trong Cycle. | Cuối Sprint |

---

## 3. Tình huống thực tế (Case Study: Tính năng "Thanh toán Ví MOMO")

### Tình huống 1: Phát hiện Bug
Trong quá trình test task "Thanh toán MOMO", bạn thấy khi nhấn "Hủy" trên app MOMO, trang web bị treo thay vì hiện thông báo.
*   **Thao tác:**
    1. Nhấn nút **New Issue**.
    2. **Title:** "[BUG] Trang web bị treo khi hủy thanh toán MOMO".
    3. **Issue Type:** Chọn `Bug`.
    4. **Priority:** Chọn `High` (Vì ảnh hưởng trực tiếp đến trải nghiệm người dùng).
    5. **Description:** Ghi rõ các bước tái hiện (Steps to reproduce) và kết quả mong muốn (Expected result).
    6. **Relations:** Chọn tính năng "Relates to" và chọn Issue gốc "Thanh toán MOMO".

### Tình huống 2: Xác nhận hoàn thành
Dev đã fix bug và báo lại. Bạn kiểm tra lại và thấy mọi thứ đã ổn.
*   **Thao tác:**
    1. Mở Bug Issue đó ra, comment: *"Đã re-test trên Staging, hoạt động tốt."* rồi chuyển trạng thái Bug sang `Closed`.
    2. Mở Issue chính "Thanh toán MOMO", nếu không còn lỗi nào khác, hãy chuyển trạng thái sang `Done`.

---

## 4. Hướng dẫn thao tác chi tiết (Step-by-Step)

### Quản lý Bug chuyên nghiệp
*   **Sử dụng Labels:** Gắn nhãn cho bug để dễ phân loại như `UI/UX`, `Functional`, `Backend`, `Mobile`.
*   **Ghi log chi tiết:** Luôn đính kèm ảnh chụp màn hình hoặc video quay lại lỗi (Plane hỗ trợ dán ảnh trực tiếp từ clipboard).
*   **Gán Assignee:** Gán đúng người Developer đã làm task đó để họ nhận được thông báo ngay lập tức.

### Quản lý Test Documentation trong Pages
Thay vì dùng file Excel rời rạc, hãy dùng **Pages**:
1. Tạo Page "Test Plan cho Module Thanh toán".
2. Liệt kê các kịch bản test (Test Cases) dưới dạng Checklist `- [ ]`.
3. Khi test đến đâu, tích vào đó để team (PO, SM) nhìn vào là biết tiến độ test.

---

## 5. Chỉ số chất lượng (Analytics)
Hãy theo dõi Dashboard để báo cáo cho team:
*   **Bug Rate:** Số lượng bug phát sinh so với số lượng Story đã hoàn thành.
*   **Bug Open vs Closed:** Team có đang sửa bug kịp tốc độ phát hiện của bạn không?
*   **Time to Resolve:** Thời gian trung bình để một bug được sửa.

---

## 6. Mẹo cho QA PROD-ready
*   **Link liên kết:** Luôn sử dụng tính năng **Relations** cực kỳ chặt chẽ. Đừng để một Bug nằm "mồ côi", nó phải luôn thuộc về một User Story nào đó.
*   **Custom Views:** Tạo một View tên là "Bugs to Verify" để bạn không bỏ sót bất kỳ lỗi nào đã được Dev báo sửa.

---
> [!IMPORTANT]
> Bạn là người cuối cùng "ký tên" cho sản phẩm trước khi đến tay khách hàng. Hãy sử dụng Plane CE để làm bằng chứng cho chất lượng mà bạn đã kiểm soát.
