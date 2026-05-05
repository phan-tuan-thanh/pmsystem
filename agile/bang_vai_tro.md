
## Bảng so sánh chi tiết các vai trò trong Agile Team

### 1. Bảng so sánh tổng quan trách nhiệm

| Tiêu chí                     | **Squad Lead**                                       | **Product Owner**            | **Scrum Master**                  | **Business Analyst**       | **Developer**                 | **QA Engineer**               |
| ------------------------------ | ---------------------------------------------------------- | ---------------------------------- | --------------------------------------- | -------------------------------- | ----------------------------------- | ----------------------------------- |
| **Mục tiêu chính**    | Dẫn dắt Squad đạt mục tiêu, phát triển con người | Tối đa hóa giá trị sản phẩm | Đảm bảo team vận hành đúng Agile | Phân tích & làm rõ yêu cầu | Xây dựng sản phẩm chất lượng | Đảm bảo chất lượng sản phẩm |
| **Câu hỏi chủ đạo** | "Squad đi đúng hướng chưa?"                          | "Cái gì đáng làm nhất?"      | "Team có gặp trở ngại gì?"         | "Yêu cầu này nghĩa là gì?" | "Làm thế nào để build?"        | "Có bug nào không?"              |
| **Tập trung vào**      | Squad (con người + delivery)                             | Sản phẩm (giá trị)             | Quy trình (cách làm)                 | Yêu cầu (cái gì)             | Giải pháp kỹ thuật              | Chất lượng                       |
| **Thuộc Scrum chuẩn?** | ❌ Không (Spotify Model)                                  | ✅ Có                             | ✅ Có                                  | ❌ Không (mở rộng)            | ✅ Có                              | ❌ Không (mở rộng)               |
| **Cấp quản lý?**      | ✅ Có (line manager)                                      | ❌ Không                          | ❌ Không                               | ❌ Không                        | ❌ Không                           | ❌ Không                           |
| **Số lượng/team**     | 1                                                          | 1                                  | 1                                       | 1-2                              | 3-9                                 | 1-3                                 |

### 2. Bảng so sánh quyền hạn & ra quyết định

| Quyền                                          | **Squad Lead** | **PO**     | **SM**  | **BA**    | **Dev**    | **QA**     |
| ----------------------------------------------- | -------------------- | ---------------- | ------------- | --------------- | ---------------- | ---------------- |
| Quyết định**CÁI GÌ**làm (scope)     | ⚠️ Tham gia        | ✅ Quyết định | ❌            | ⚠️ Đề xuất | ❌               | ❌               |
| Quyết định**THỨ TỰ ƯU TIÊN**       | ⚠️ Tham gia        | ✅ Quyết định | ❌            | ⚠️ Đề xuất | ❌               | ❌               |
| Quyết định**CÁCH LÀM**kỹ thuật     | ✅ Quyết định     | ❌               | ❌            | ❌              | ✅ Quyết định | ⚠️ Tham gia    |
| Quyết định**QUY TRÌNH**               | ⚠️ Tham gia        | ❌               | ✅ Facilitate | ❌              | ⚠️ Tham gia    | ⚠️ Tham gia    |
| **Chấp nhận/từ chối**kết quả Sprint | ⚠️ Hỗ trợ        | ✅ Quyết định | ❌            | ⚠️ Hỗ trợ   | ❌               | ⚠️ Verify      |
| **Tuyển dụng**member                    | ✅ Có               | ❌               | ❌            | ❌              | ⚠️ Phỏng vấn | ⚠️ Phỏng vấn |
| **Performance review**                    | ✅ Có               | ❌               | ❌            | ❌              | ❌               | ❌               |
| **Phê duyệt nghỉ phép**               | ✅ Có               | ❌               | ❌            | ❌              | ❌               | ❌               |
| **Quyết định release**                 | ⚠️ Tham gia        | ✅ Quyết định | ❌            | ❌              | ⚠️ Đề xuất  | ✅ Sign-off      |
| **Loại bỏ impediment**cấp team         | ⚠️ Hỗ trợ        | ❌               | ✅ Chính     | ❌              | ❌               | ❌               |
| **Loại bỏ impediment**cấp tổ chức    | ✅ Có               | ⚠️ Tham gia    | ⚠️ Escalate | ❌              | ❌               | ❌               |

*Ghi chú: ✅ Trách nhiệm chính | ⚠️ Tham gia/hỗ trợ | ❌ Không phụ trách*

### 3. Bảng so sánh hoạt động hàng ngày

| Hoạt động                    | **Squad Lead**  | **PO**        | **SM**  | **BA**      | **Dev**                  | **QA**              |
| ------------------------------- | --------------------- | ------------------- | ------------- | ----------------- | ------------------------------ | ------------------------- |
| **Daily Standup**         | Tham gia (lắng nghe) | Tham gia            | Facilitate    | Tham gia          | Báo cáo                      | Báo cáo                 |
| **Sprint Planning**       | Tham gia              | Trình bày backlog | Facilitate    | Hỗ trợ làm rõ | Ước lượng, cam kết        | Ước lượng test effort |
| **Backlog Refinement**    | Đôi khi             | Chủ trì           | Facilitate    | Hỗ trợ chính   | Đặt câu hỏi, ước lượng | Đặt câu hỏi về test  |
| **Sprint Review**         | Tham gia              | Chủ trì, demo     | Facilitate    | Hỗ trợ demo     | Demo sản phẩm                | Báo cáo chất lượng   |
| **Retrospective**         | Đôi khi tham gia    | Đôi khi           | Facilitate    | Tham gia          | Tham gia                       | Tham gia                  |
| **Code/Coding**           | ⚠️ Đôi khi        | ❌                  | ❌            | ❌                | ✅ Chính                      | ⚠️ Test code            |
| **Code Review**           | ✅ PR phức tạp      | ❌                  | ❌            | ❌                | ✅ Chính                      | ❌                        |
| **Viết User Story**      | ❌                    | ✅ Chính           | ❌            | ✅ Hỗ trợ       | ❌                             | ❌                        |
| **Viết Test Case**       | ❌                    | ❌                  | ❌            | ⚠️ Hỗ trợ     | ⚠️ Unit test                 | ✅ Chính                 |
| **1-on-1 với member**    | ✅ Định kỳ         | ❌                  | ⚠️ Coaching | ❌                | ❌                             | ❌                        |
| **Họp với stakeholder** | ✅ Định kỳ         | ✅ Chính           | ❌            | ✅ Có            | ❌                             | ❌                        |

### 4. Bảng so sánh kỹ năng cần có

| Kỹ năng                      | **Squad Lead** | **PO** | **SM** | **BA** | **Dev** | **QA** |
| ------------------------------ | -------------------- | ------------ | ------------ | ------------ | ------------- | ------------ |
| **Technical/Coding**     | ⭐⭐⭐⭐             | ⭐⭐         | ⭐           | ⭐⭐         | ⭐⭐⭐⭐⭐    | ⭐⭐⭐       |
| **Business domain**      | ⭐⭐⭐               | ⭐⭐⭐⭐⭐   | ⭐⭐         | ⭐⭐⭐⭐⭐   | ⭐⭐          | ⭐⭐⭐       |
| **Leadership**           | ⭐⭐⭐⭐⭐           | ⭐⭐⭐       | ⭐⭐⭐⭐     | ⭐⭐         | ⭐⭐          | ⭐⭐         |
| **Giao tiếp**           | ⭐⭐⭐⭐⭐           | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐⭐   | ⭐⭐⭐        | ⭐⭐⭐⭐     |
| **Coaching/Mentoring**   | ⭐⭐⭐⭐⭐           | ⭐⭐         | ⭐⭐⭐⭐⭐   | ⭐⭐         | ⭐⭐⭐        | ⭐⭐         |
| **Phân tích**          | ⭐⭐⭐⭐             | ⭐⭐⭐⭐     | ⭐⭐⭐       | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐      | ⭐⭐⭐⭐⭐   |
| **Quản lý xung đột** | ⭐⭐⭐⭐⭐           | ⭐⭐⭐       | ⭐⭐⭐⭐⭐   | ⭐⭐⭐       | ⭐⭐          | ⭐⭐         |
| **Tư duy hệ thống**   | ⭐⭐⭐⭐⭐           | ⭐⭐⭐⭐     | ⭐⭐⭐       | ⭐⭐⭐⭐     | ⭐⭐⭐⭐      | ⭐⭐⭐⭐     |
| **Detail-oriented**      | ⭐⭐⭐               | ⭐⭐⭐⭐     | ⭐⭐⭐       | ⭐⭐⭐⭐⭐   | ⭐⭐⭐⭐      | ⭐⭐⭐⭐⭐   |
| **Hiểu Agile/Scrum**    | ⭐⭐⭐⭐             | ⭐⭐⭐⭐     | ⭐⭐⭐⭐⭐   | ⭐⭐⭐       | ⭐⭐⭐        | ⭐⭐⭐       |

### 5. Bảng so sánh KPI/Metric đo lường

| Vai trò                   | KPI/Metric chính                                                                                                                                                                                      |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Squad Lead**       | • Squad health (eNPS, retention rate)``• Delivery predictability``• OKR completion rate``• Member growth (promotion rate)``• Cross-Squad collaboration                |
| **Product Owner**    | • Product ROI, revenue impact``• User adoption, NPS``• Feature usage rate``• Time-to-market``• Backlog health (DEEP - Detailed, Estimated, Emergent, Prioritized)     |
| **Scrum Master**     | • Velocity stability``• Sprint goal achievement rate``• Impediment resolution time``• Team happiness index``• Ceremony effectiveness                                  |
| **Business Analyst** | • Requirement clarity (số lần clarify lại)``• User story quality (INVEST score)``• Số lượng change request sau dev``• UAT pass rate``• Stakeholder satisfaction |
| **Developer**        | • Velocity (Story Points/Sprint)``• Code quality (test coverage, complexity)``• Bug rate (bugs/feature)``• PR review time``• Technical debt ratio                     |
| **QA Engineer**      | • Defect detection rate (trước vs sau release)``• Test coverage (manual + auto)``• Bug escape rate``• Automation ratio``• Mean time to detect (MTTD)                |

### 6. Bảng so sánh quan hệ làm việc & báo cáo

| Vai trò                   | **Báo cáo lên**               | **Làm việc chặt với**       | **Quản lý**                        |
| -------------------------- | -------------------------------------- | ------------------------------------- | ------------------------------------------ |
| **Squad Lead**       | Tribe Lead / Engineering Manager / CTO | PO, SM, Chapter Lead, Tribe Lead      | Toàn bộ Squad members                    |
| **Product Owner**    | Product Manager / Head of Product      | Stakeholder, Squad Lead, Dev Team     | Product Backlog (không quản lý người) |
| **Scrum Master**     | Agile Coach / Squad Lead / RTE         | PO, Dev Team, Squad Lead              | Quy trình (không quản lý người)      |
| **Business Analyst** | BA Lead / PO / PM                      | PO, Stakeholder, Dev, QA              | Tài liệu nghiệp vụ                     |
| **Developer**        | Tech Lead / Squad Lead / Chapter Lead  | Toàn team, đặc biệt Dev khác, QA | Codebase phần phụ trách                 |
| **QA Engineer**      | QA Lead / Chapter Lead / Squad Lead    | Dev, BA, PO                           | Test suite, bug tracker                    |

### 7. Bảng so sánh khi xảy ra vấn đề

| Tình huống                                  | Ai xử lý chính?                                                                |
| --------------------------------------------- | --------------------------------------------------------------------------------- |
| Yêu cầu không rõ ràng                    | **BA**(làm rõ) →**PO**(quyết định)                              |
| Bug trên production                          | **Dev**(fix) →**QA**(verify) →**SM**(theo dõi)               |
| Sprint Goal khó đạt                        | **SM**(facilitate) +**PO**(re-prioritize) +**Dev**(re-estimate) |
| Conflict giữa 2 dev                          | **Squad Lead**(chính) →**SM**(hỗ trợ)                             |
| Stakeholder thay đổi yêu cầu giữa sprint | **PO**(đàm phán) →**SM**(bảo vệ team)                           |
| Member muốn nghỉ việc                      | **Squad Lead**(1-on-1, retention)                                           |
| Velocity giảm liên tục                     | **SM**(root cause) +**Squad Lead**(hỗ trợ)                          |
| Technical debt nhiều                         | **Tech Lead**+**Squad Lead**(đề xuất) →**PO**(cấp budget)  |
| Quality kém                                  | **QA**(báo cáo) +**Squad Lead**(định hướng)                     |
| Deadline business gấp                        | **PO**+**Squad Lead**(cân đối scope/timeline)                      |
| Member skill yếu                             | **Squad Lead**+**Chapter Lead**(training plan)                        |
| Cross-team dependency bị block               | **Squad Lead**(escalate) →**Tribe Lead**                             |

### 8. Bảng tóm tắt: 1 câu định nghĩa

| Vai trò                   | Định nghĩa 1 câu                                                                                                |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| **Squad Lead**       | Người dẫn dắt Squad về cả con người và định hướng kỹ thuật, là cầu nối giữa Squad và tổ chức. |
| **Product Owner**    | Người quyết định*cái gì*nên làm và *thứ tự ưu tiên* , đại diện cho giá trị sản phẩm.       |
| **Scrum Master**     | Servant leader đảm bảo team vận hành Agile hiệu quả, loại bỏ trở ngại quy trình.                        |
| **Business Analyst** | Cầu nối business và kỹ thuật, biến yêu cầu mơ hồ thành story rõ ràng.                                  |
| **Developer**        | Người biến yêu cầu thành sản phẩm chạy được với chất lượng kỹ thuật cao.                          |
| **QA Engineer**      | Người gác cổng chất lượng, đảm bảo sản phẩm đáng tin cậy trước khi đến tay user.                 |

---

### Lưu ý ứng dụng vào tool PM

Khi setup phân quyền trong NocoBase/Plane/OpenProject, anh có thể tham khảo template phân quyền sau dựa trên các bảng trên:

| Quyền trên tool    | Squad Lead | PO   | SM | BA   | Dev  | QA |
| -------------------- | ---------- | ---- | -- | ---- | ---- | -- |
| Tạo/xóa Project    | ✅         | ✅   | ❌ | ❌   | ❌   | ❌ |
| Edit Backlog         | ✅         | ✅   | ❌ | ⚠️ | ❌   | ❌ |
| Edit Sprint config   | ✅         | ⚠️ | ✅ | ❌   | ❌   | ❌ |
| Tạo/edit User Story | ✅         | ✅   | ❌ | ✅   | ⚠️ | ❌ |
| Update task status   | ✅         | ✅   | ✅ | ✅   | ✅   | ✅ |
| Tạo Bug             | ✅         | ✅   | ✅ | ✅   | ✅   | ✅ |
| Close Bug            | ✅         | ⚠️ | ❌ | ❌   | ✅   | ✅ |
| Edit Wiki/Docs       | ✅         | ✅   | ✅ | ✅   | ✅   | ✅ |
| Xem Report/Dashboard | ✅         | ✅   | ✅ | ✅   | ✅   | ✅ |
| Quản lý member     | ✅         | ❌   | ❌ | ❌   | ❌   | ❌ |
| Cấu hình workflow  | ✅         | ⚠️ | ✅ | ❌   | ❌   | ❌ |
