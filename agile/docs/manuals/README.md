# Hướng dẫn sử dụng Hệ thống Quản lý Dự án (PMS) - Plane CE

Chào mừng bạn đến với bộ tài liệu hướng dẫn vận hành Agile trên nền tảng Plane CE. Bộ tài liệu này được thiết kế riêng biệt cho từng vai trò trong Squad, giúp người mới bắt đầu có thể nhanh chóng làm quen với quy trình làm việc chuyên nghiệp (PROD-ready).

## 1. Mục lục hướng dẫn theo vai trò

Dưới đây là các tài liệu hướng dẫn chi tiết cho từng vị trí. Vui lòng chọn đúng vai trò của bạn để bắt đầu:

*   📘 [**Squad Lead**](manual_squad_lead.md): Quản trị dự án, quản lý thành viên và theo dõi hiệu suất tổng thể qua Analytics.
*   📙 [**Product Owner (PO)**](manual_product_owner.md): Quản lý Backlog, ưu tiên tính năng và xây dựng lộ trình sản phẩm qua Modules.
*   📗 [**Scrum Master (SM)**](manual_scrum_master.md): Điều phối các buổi họp, vận hành Cycles (Sprints) và tối ưu hóa workflow.
*   📒 [**Business Analyst (BA)**](manual_business_analyst.md): Soạn thảo User Story chi tiết và quản lý kho tri thức trong Pages.
*   💻 [**Developer**](manual_developer.md): Thực thi công việc, cập nhật trạng thái và phối hợp kỹ thuật trong Cycles.
*   🛡️ [**QA Engineer**](manual_qa_engineer.md): Kiểm soát chất lượng, quản lý Bug và xác nhận kết quả cuối mỗi chu kỳ.

---

## 2. Bản đồ thuật ngữ (Agile Mapping)

Nếu bạn là người mới, hãy làm quen với cách Plane CE gọi tên các khái niệm Agile:

| Thuật ngữ Agile | Tên gọi trong Plane CE | Mô tả |
| :--- | :--- | :--- |
| **User Story / Task / Bug** | **Issue** | Đơn vị công việc nhỏ nhất. |
| **Sprint** | **Cycle** | Chu kỳ làm việc cố định (thường là 2 tuần). |
| **Feature / Epic / Roadmap** | **Module** | Nhóm các Issue liên quan để hoàn thành một tính năng lớn. |
| **Documentation / Wiki** | **Pages** | Nơi lưu trữ tài liệu nghiệp vụ, yêu cầu chi tiết. |
| **Backlog** | **Backlog (State)** | Danh sách các công việc chưa được đưa vào chu kỳ thực hiện. |
| **Dashboard / Report** | **Analytics** | Các biểu đồ đo lường (Burndown, Velocity...). |

---

## 3. Case Study xuyên suốt: Tính năng "Thanh toán Ví điện tử"

Để các hướng dẫn trở nên tự nhiên và dễ hiểu, chúng ta sẽ cùng theo dõi quá trình xây dựng tính năng **"Thanh toán qua Ví MOMO"** cho hệ thống E-commerce:

1.  **Giai đoạn chuẩn bị:** PO tạo Module "Thanh toán" và Issue "Tích hợp MOMO".
2.  **Giai đoạn chi tiết:** BA viết đặc tả giao diện và luồng dữ liệu vào mục Pages.
3.  **Giai đoạn thực hiện:** SM đưa Issue vào Cycle 01. Developer nhận task và bắt đầu code.
4.  **Giai đoạn kiểm thử:** QA phát hiện bug "Không nhận được phản hồi từ MOMO" và tạo Issue loại Bug.
5.  **Giai đoạn hoàn tất:** Squad Lead xem Dashboard để đảm bảo tính năng kịp ngày ra mắt.

---

## 4. Hướng dẫn chung cho mọi thành viên

### Bước 1: Đăng nhập
Truy cập địa chỉ hệ thống (thông tin do IT cung cấp) và sử dụng tài khoản công ty để đăng nhập.

### Bước 2: Thiết lập cá nhân
*   Click vào Profile (góc dưới bên trái).
*   Cập nhật **Avatar** và **Display Name** để đồng nghiệp dễ nhận diện.
*   Thiết lập **Notifications** để không bỏ lỡ các cập nhật quan trọng.

### Bước 3: Làm quen với Workspace
*   **Projects:** Danh sách các dự án bạn tham gia.
*   **My Issues:** Nơi tập hợp tất cả các task được giao cho bạn.

---
> [!TIP]
> Hãy luôn giữ cho dữ liệu trên Plane "sạch" và "cập nhật". Một hệ thống PMS tốt chỉ khi dữ liệu trong đó phản ánh đúng thực tế công việc.
