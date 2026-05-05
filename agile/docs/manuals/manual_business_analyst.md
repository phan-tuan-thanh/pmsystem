# Hướng dẫn dành cho Business Analyst (BA) trên Plane CE

## 1. Vai trò của bạn
Là **Business Analyst**, bạn là cầu nối giữa Business và Kỹ thuật. Trên Plane CE, nhiệm vụ của bạn là làm rõ các yêu cầu mơ hồ từ PO thành các User Story chi tiết, dễ hiểu cho Developer và QA.

**Câu hỏi chủ đạo:** *"Yêu cầu này cụ thể gồm những luồng xử lý nào? Điều kiện chấp nhận là gì?"*

---

## 2. Luồng công việc chuẩn (Standard Workflow)

| Giai đoạn | Hành động trên Plane CE | Tần suất |
| :--- | :--- | :--- |
| **Làm rõ yêu cầu** | Viết nội dung chi tiết cho Issue, thêm Acceptance Criteria. | Hàng ngày |
| **Quản lý kho tri thức** | Soạn thảo quy trình, tài liệu nghiệp vụ trong **Pages**. | Theo từng tính năng |
| **Phân rã (Decomposition)**| Chia nhỏ một Issue lớn thành các Sub-issues kỹ thuật. | Trước Sprint Planning |
| **Hỗ trợ Planning** | Giải đáp thắc mắc về nghiệp vụ cho Team trong buổi họp. | Đầu mỗi Cycle |

---

## 3. Tình huống thực tế (Case Study: Tính năng "Thanh toán Ví MOMO")

### Tình huống 1: Làm chi tiết User Story
PO đã tạo Issue "Thanh toán qua ví MOMO". Bạn cần vào bổ sung nội dung.
*   **Thao tác:** Mở Issue đó lên.
*   **Nội dung bổ sung:**
    *   **Description:** Vẽ luồng: User chọn MOMO -> Redirect sang app MOMO -> Thanh toán -> Redirect về Web.
    *   **Acceptance Criteria (AC):**
        1. User phải thấy logo MOMO ở trang thanh toán.
        2. Nếu thanh toán thành công, đơn hàng chuyển trạng thái "Đã thanh toán".
        3. Nếu user hủy thanh toán, phải có thông báo lỗi rõ ràng.

### Tình huống 2: Lưu trữ tài liệu quy trình
Tính năng thanh toán có nhiều quy định về bảo mật và đối soát.
*   **Thao tác:** Vào mục **Pages** -> Tạo Page mới tên là "Quy trình tích hợp MOMO".
*   **Nội dung:** Viết chi tiết các thông số API, logic tính phí, quy trình đối soát cuối ngày.
*   **Liên kết:** Copy link của Page này và dán vào phần Description của Issue tương ứng để Dev dễ tìm.

---

## 4. Hướng dẫn thao tác chi tiết (Step-by-Step)

### Sử dụng trình soạn thảo Markdown mạnh mẽ
Plane hỗ trợ Markdown hoàn chỉnh. Hãy tận dụng để tài liệu chuyên nghiệp hơn:
*   Dùng `#`, `##` cho tiêu đề.
*   Dùng `- [ ]` để tạo Checklist cho Acceptance Criteria.
*   Dùng `>` để làm nổi bật các lưu ý (Note).
*   Chèn hình ảnh/UI mockup trực tiếp vào Issue bằng cách kéo thả.

### Quản lý Sub-issues
Nếu "Tích hợp MOMO" quá lớn, hãy chia nhỏ:
1. Trong màn hình chi tiết Issue, tìm mục **Sub-issues**.
2. Thêm các task nhỏ như: "Thiết kế UI thanh toán", "Viết API kết nối MOMO", "Xử lý Callback".
3. Việc này giúp Dev dễ ước lượng và QA dễ test từng phần.

---

## 5. Tương tác và Phối hợp
*   **Tag đồng nghiệp:** Dùng `@TenDongNghiep` trong comment để hỏi ý kiến PO hoặc giải thích cho Dev.
*   **Activity Log:** Xem lại lịch sử thay đổi của Issue để biết yêu cầu đã bị sửa đổi bởi ai và khi nào.

---

## 6. Mẹo cho BA PROD-ready
*   **Sử dụng Pages làm Wiki:** Đừng để tài liệu nghiệp vụ nằm rải rác ở Google Docs hay Slack. Hãy tập trung tất cả vào **Pages** của Plane CE để tạo thành "Single Source of Truth".
*   **Liên kết thông minh:** Luôn dùng tính năng **Relations** để liên kết các Issue liên quan đến nhau (ví dụ: Task "Tích hợp MOMO" liên quan đến Task "Cập nhật trạng thái đơn hàng").

---
> [!TIP]
> Một User Story tốt là một User Story mà Developer đọc vào không cần phải hỏi lại bạn. Hãy cố gắng đạt được tiêu chuẩn "Sạch - Rõ - Đủ" trên Plane CE.
