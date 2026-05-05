# Hướng dẫn dành cho Scrum Master (SM) trên Plane CE

## 1. Vai trò của bạn
Là **Scrum Master**, bạn là "Servant Leader" đảm bảo team vận hành Agile trơn tru. Trên Plane CE, bạn là người "giữ nhịp" cho dự án thông qua việc quản lý các chu kỳ làm việc và loại bỏ các trở ngại về quy trình.

**Câu hỏi chủ đạo:** *"Team có đang bị block chỗ nào không? Quy trình hiện tại có giúp team làm việc nhanh hơn không?"*

---

## 2. Luồng công việc chuẩn (Standard Workflow)

| Giai đoạn | Hành động trên Plane CE | Tần suất |
| :--- | :--- | :--- |
| **Khởi động chu kỳ** | Tạo mới và cấu hình **Cycle** (Sprint). | Đầu mỗi Sprint |
| **Theo dõi hàng ngày** | Sử dụng **Board View** trong buổi Daily Standup. | Hàng ngày |
| **Xử lý trở ngại** | Theo dõi các Issue bị "Stuck" (ngâm lâu) để hỗ trợ. | Hàng ngày |
| **Kết thúc chu kỳ** | Đóng Cycle hiện tại, chuyển Issue dở dang sang Cycle mới. | Cuối mỗi Sprint |
| **Cải tiến quy trình** | Xem Analytics (Burndown) để thảo luận trong buổi Retro. | Cuối mỗi Sprint |

---

## 3. Tình huống thực tế (Case Study: Tính năng "Thanh toán Ví MOMO")

### Tình huống 1: Chuẩn bị Sprint Planning
Team quyết định làm tính năng MOMO trong 2 tuần tới.
*   **Thao tác:** Vào mục **Cycles** -> Tạo Cycle mới (ví dụ: "Cycle 15: Payment Integration").
*   **Thiết lập:** Chọn ngày bắt đầu và kết thúc (2 tuần).
*   **Đưa task vào:** Kéo Issue "Thanh toán qua ví MOMO" từ Backlog vào Cycle này.

### Tình huống 2: Điều phối Daily Standup
Trong buổi họp sáng, bạn mở Plane lên và chiếu màn hình cho cả team.
*   **Thao tác:** Vào Cycle 15 -> Chọn View **Board**.
*   **Phân tích:** Bạn thấy task "Viết API MOMO" của Dev A đã ở trạng thái 'In Progress' 3 ngày rồi mà chưa xong.
*   **Hành động:** Hỏi trực tiếp Dev A xem có khó khăn gì không. Nếu bị block do thiếu tài liệu, bạn tag BA vào để xử lý ngay.

---

## 4. Hướng dẫn thao tác chi tiết (Step-by-Step)

### Quản lý Cycle (Sprint) chuyên nghiệp
1.  **Cấu hình Cycle:** Luôn đặt mục tiêu ngắn gọn cho Cycle trong phần Description (ví dụ: "Hoàn thành tích hợp thanh toán và sửa 10 bug tồn đọng").
2.  **Chế độ xem Board (Kanban):**
    *   Sắp xếp các cột theo luồng: `Todo` -> `In Progress` -> `In Review` -> `Done`.
    *   Sử dụng **Filters** để lọc theo Assignee để từng người báo cáo nhanh hơn.
3.  **Chốt Cycle:** Khi kết thúc Sprint, hãy nhấn **Complete Cycle**. Plane sẽ hỏi bạn xử lý các Issue chưa xong thế nào (thường là chuyển về Backlog hoặc Cycle tiếp theo).

### Thiết lập Layout cho Team
Plane cung cấp nhiều cách xem, bạn nên hướng dẫn team dùng đúng lúc:
*   **Kanban:** Tốt nhất cho Daily Standup (nhìn luồng việc).
*   **Spreadsheet:** Tốt nhất khi cần cập nhật hàng loạt Issue (như đổi Priority, gắn Label).
*   **Gantt:** Tốt nhất khi cần nhìn sự phụ thuộc (Dependencies) giữa các task.

---

## 5. Phân tích hiệu suất (Analytics)
Bạn cần nắm vững các biểu đồ sau trên Plane để điều phối:
*   **Burndown Chart:** Đường màu xanh (thực tế) có bám sát đường màu xám (kế hoạch) không? Nếu đường màu xanh nằm ngang quá lâu, team đang gặp vấn đề.
*   **Cumulative Flow Diagram (CFD):** Giúp phát hiện "nút thắt cổ chai" (Bottleneck) - ví dụ: Cột `In Review` quá dày nghĩa là QA đang bị quá tải.

---

## 6. Mẹo cho SM PROD-ready
*   **Làm sạch Board:** Cuối mỗi ngày, hãy nhắc nhở team cập nhật trạng thái Issue. "Dữ liệu sai dẫn đến quyết định sai".
*   **Sử dụng Automations:** Tận dụng các tính năng tự động của Plane (nếu có) để chuyển trạng thái Issue khi có liên kết Git hoặc tự động đóng Issue khi Sub-issues hoàn thành.

---
> [!IMPORTANT]
> Bạn không phải là người giao việc, bạn là người giúp việc trôi chảy. Hãy dùng Plane CE như một tấm gương phản chiếu thực tế để team tự điều chỉnh.
