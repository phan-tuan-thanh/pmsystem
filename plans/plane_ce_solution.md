# Plane CE + AI Solution

## Mục tiêu

- Bỏ NocoBase trong hạ tầng hiện tại.
- Chuyển sang dùng Plane CE làm nền tảng business platform.
- Bổ sung AI hỗ trợ cho quy trình Agile: tạo task/backlog, đề xuất sprint, gợi ý ưu tiên, phân công và review tiến độ.
- Giữ lại hạ tầng chung hiện có: Traefik, Authentik, Postgres, Redis.

## Vấn đề cần giải quyết

- NocoBase không đáp ứng tốt yêu cầu giao diện Agile và trải nghiệm quản lý dự án.
- Cần nền tảng dễ mở rộng, dễ tích hợp SSO và AI.
- Yêu cầu self-hosted, dễ backup, dễ vận hành.

## Giải pháp đề xuất

1. Thay `platform/nocobase/` bằng `platform/plane-ce/`.
2. Xây dựng `plane-ce` như một service riêng, deploy bằng Docker Compose.
3. Sử dụng Traefik để routing HTTPS và tên miền:
   - `app.${DOMAIN}` cho Plane CE
4. Sử dụng Authentik làm Identity Provider và SSO:
   - Plane CE sẽ xác thực qua Authentik khi cần.
5. Sử dụng Postgres làm database chính cho Plane CE.
6. Sử dụng Redis cho cache/queue nếu cần trong Plane CE hoặc AI service.
7. Thiết kế một service AI hỗ trợ:
   - API hoặc microservice riêng, có thể kết nối vào Plane CE.
   - Hỗ trợ tự động hóa backlog, phân tích sprint, tạo ghi chú, gợi ý cải tiến.

## Yêu cầu extension hỗ trợ Agile trên Plane CE

Cần xây dựng các extension/micro-app mở rộng cho Plane CE để tối ưu quản lý dự án Agile, bao gồm:

- Dashboard Agile tổng quan:
  - Burn-down/burn-up chart
  - Sprint progress và velocity
  - Task trạng thái theo nhóm/nhân sự
- Backlog management:
  - Kéo-thả ưu tiên backlog
  - Tự động phân loại task theo epic/feature/priority
  - Template tạo nhanh user story/task/bug
- Sprint planning:
  - Gợi ý phân bổ task theo năng lực và tải công việc
  - Dự đoán độ phức tạp/story point từ mô tả
  - Tạo sprint plan và ngày bắt đầu/kết thúc tự động
- Task board/collaboration:
  - Kanban board tùy chỉnh trạng thái Agile
  - Comment/mention và update trạng thái tự động
  - Tích hợp notification/alert cho deadline và blocker
- Reporting & retrospective:
  - Tạo báo cáo sprint summary
  - Thống kê issue trend và cycle time
  - Hỗ trợ ghi nhận retrospective action items
- Performance tracking & analytics:
  - Theo dõi tiến độ dự án theo milestone, sprint và release
  - Theo dõi tiến độ task theo trạng thái, backlog, và deadline
  - Đo lường năng suất nhân sự: throughput, work-in-progress, task completion rate
  - Báo cáo hiệu suất nhóm và cá nhân theo sprint/period
  - So sánh hiệu quả khi áp dụng Agile so với phương pháp Waterfall:
    - lead time vs cycle time
    - release frequency
    - change failure rate
    - predictability và delivery pace
- AI assistant extension:
  - Gợi ý nội dung user story, checklist, acceptance criteria
  - Đề xuất cải tiến sprint/project từ dữ liệu lịch sử
  - Tự động tạo task/issue từ mô tả nhanh

Các extension này nên được thiết kế dưới dạng module mở rộng của Plane CE để có thể bật/tắt, nâng cấp độc lập và dễ bảo trì.

## Kiến trúc hạ tầng

```
/opt/platform/
├── .env
├── compose.shared.yml
├── traefik/
├── authentik/
├── plane-ce/
│   ├── docker-compose.yml
│   └── data/
├── postgres/
├── redis/
└── scripts/
```

## Nội dung chính của giải pháp

- `platform/.env`: cấu hình chung domain, mật khẩu, biến môi trường.
- `platform/compose.shared.yml`: cấu hình compose dùng chung, network, restart policy, logging.
- `platform/traefik/docker-compose.yml`: reverse proxy, HTTPS, Let's Encrypt.
- `platform/authentik/docker-compose.yml`: dịch vụ SSO.
- `platform/postgres/docker-compose.yml`: DB cho Authentik và Plane CE.
- `platform/redis/docker-compose.yml`: cache/queue chung.
- `platform/plane-ce/docker-compose.yml`: dịch vụ Plane CE.
- `platform/scripts/*.sh`: deploy, down, backup, kiểm tra.

## Tạo dữ liệu demo Agile

- Mục tiêu: tạo bộ dữ liệu demo Agile đầy đủ để kiểm chứng Plane CE + AI chạy đúng kịch bản quản lý dự án.
- Dữ liệu demo cần bao gồm:
  - Users / Team members
  - Projects
  - Epics / Features
  - Sprints
  - Tasks / Issues / Bugs
  - Comments / Activity
  - Backlog / Priority / Story points
- Kịch bản dữ liệu tham chiếu:
  - 20 dự án
  - ~85 sprint
  - ~1.000 task
  - ~30 users
  - 500 bình luận/hoạt động
- Phương án:
  1. Giữ lại nội dung `platform/scripts/seed_demo/README.md` như tài liệu legacy tham chiếu NocoBase.
  2. Viết lại seed script cho Plane CE, có thể đặt ở `platform/scripts/seed_demo_plane_ce/`.
  3. Seed dữ liệu từ cấu hình schema Plane CE hoặc qua API Plane CE.
  4. Bổ sung tùy chọn `--reset` để tái tạo dữ liệu clean.

### Dự án demo Agile tham chiếu

- Tạo 1 project mẫu đặc thù để người dùng tham khảo cách áp dụng Agile:
  - Mô tả rõ mục tiêu dự án, giá trị khách hàng, roadmap ngắn hạn và dài hạn.
  - Bao gồm đầy đủ các vai trò cơ bản: Product Owner, Scrum Master, Developer, QA, Business Analyst, UX, Stakeholder.
  - Mỗi role có ví dụ nhiệm vụ, ví dụ công việc hàng ngày và mô tả trách nhiệm cụ thể.
- Dữ liệu trong project demo cần giải thích rõ:
  - Cách phân chia epic/feature thành user story và task.
  - Cách xác định và gán story point cho mỗi task.
  - Cách tính sprint velocity và sử dụng nó để lên kế hoạch sprint tiếp theo.
  - Cách theo dõi tiến độ bằng sprint burndown, trạng thái task và bảng Kanban.
  - Cách đánh giá năng suất và hiệu quả của từng role với các chỉ số như throughput, cycle time, completion rate, workload balance.
- Lưu trữ lịch sử sprint đầy đủ với báo cáo cho mỗi sprint:
  - sprint summary, completed story points, uncompleted work
  - sprint review feedback
  - retrospective action items
  - lessons learned và trend analysis qua nhiều sprint
- Tài liệu đi kèm project demo:
  - Hướng dẫn đọc báo cáo sprint.
  - Ví dụ cách đo lường hiệu quả nhân sự và nhóm.
  - So sánh Agile với Waterfall qua các chỉ số thực tế của project demo.
- Seeding project demo này nên tạo thành một bài học mẫu, giúp người dùng hiểu rõ:
  - vai trò từng thành viên trong quy trình Agile,
  - cách áp dụng backlog refinement, sprint planning và daily standup,
  - cách đo lường và cải tiến sau mỗi sprint.

### Hướng dẫn chi tiết cho từng role

- Product Owner (PO):
  - Step 1: Xác định giá trị và mục tiêu sản phẩm, tạo project vision.
  - Step 2: Ưu tiên backlog theo giá trị kinh doanh và rủi ro.
  - Step 3: Viết user story rõ ràng, gồm tiêu chí chấp nhận.
  - Step 4: Tham gia sprint planning để giải thích yêu cầu và xác nhận scope.
  - Step 5: Review kết quả cuối sprint và đưa feedback cho team.
  - Gợi ý: Luôn giữ backlog gọn, cập nhật dựa trên phản hồi khách hàng.

- Scrum Master:
  - Step 1: Thiết lập quy trình Agile cho team và đảm bảo mọi người hiểu cách làm.
  - Step 2: Tổ chức daily standup, hỗ trợ gỡ blocker và theo dõi impediment.
  - Step 3: Bảo vệ team khỏi yêu cầu ngoài scope và giúp team tập trung vào sprint goal.
  - Step 4: Facilitate retrospective để thu bài học và cải tiến.
  - Gợi ý: Sử dụng dashboard để theo dõi team velocity và WIP balance.

- Developer:
  - Step 1: Tham gia refinement để ước lượng, tách task và gán story point.
  - Step 2: Lấy task từ sprint backlog, cập nhật trạng thái trên board.
  - Step 3: Làm rõ yêu cầu với PO nếu cần và commit tiến độ liên tục.
  - Step 4: Đảm bảo code hoàn thành đủ tiêu chí chấp nhận trước khi đóng task.
  - Gợi ý: Tập trung hoàn thành task nhỏ, giảm task bị kéo dài qua nhiều sprint.

- QA:
  - Step 1: Tham gia review yêu cầu và xác định tiêu chí kiểm thử cho user story.
  - Step 2: Viết test case cho chức năng và bắt đầu kiểm thử sớm.
  - Step 3: Báo cáo lỗi, phân loại theo severity và giúp priorize sửa lỗi.
  - Step 4: Xác nhận task đáp ứng acceptance criteria trước khi chuyển sang DONE.
  - Gợi ý: Tích hợp tự động hóa test nếu có thể để tăng tốc nghiệm thu.

- Business Analyst (BA):
  - Step 1: Thu thập, phân tích yêu cầu và chuyển thành user story rõ ràng.
  - Step 2: Hỗ trợ PO lên backlog, phân loại user story theo business value.
  - Step 3: Giải thích yêu cầu cho Developer và QA.
  - Step 4: Tạo tài liệu tham chiếu, luồng nghiệp vụ và sơ đồ cho team.
  - Gợi ý: Dùng template story/acceptance criteria chuẩn để giảm sai sót.

- UX Designer:
  - Step 1: Xác định trải nghiệm người dùng và thiết kế wireframe/prototype.
  - Step 2: Tham gia refinement để đảm bảo UI/UX phù hợp với user story.
  - Step 3: Cập nhật thiết kế sau phản hồi từ PO, BA và người dùng.
  - Step 4: Kiểm tra và xác nhận UI/UX trên môi trường demo.
  - Gợi ý: Cung cấp examples visual giúp team hiểu nhanh hơn yêu cầu.

- Stakeholder:
  - Step 1: Đưa ra mục tiêu chiến lược, kỳ vọng và ưu tiên cho dự án.
  - Step 2: Tham gia sprint review để xem kết quả và đánh giá giá trị.
  - Step 3: Đưa feedback thực tế, xác nhận hướng đi, và ưu tiên cho tính năng tiếp theo.
  - Gợi ý: Tham gia đều đặn và cung cấp phản hồi cụ thể để tránh thay đổi lớn giữa sprint.

- Hướng xử lý chung:
  - Role nào cũng nên sử dụng task board và báo cáo sprint để theo dõi tiến độ.
  - Nếu có blocker, hãy cập nhật ngay trên task và báo cho Scrum Master.
  - Dựa trên sprint retrospective, nhóm cần ghi nhận action item và cải tiến liên tục.

## Lộ trình triển khai

1. Hoàn tất tài liệu giải pháp và chốt phương án.
2. Thiết kế `docker-compose.yml` cho Plane CE.
3. Tạo placeholder `platform/plane-ce/` và cấu trúc cơ bản.
4. Tạo service AI nếu cần, có thể đặt trong `platform/plane-ai/` hoặc nội bộ của Plane CE.
5. Triển khai dev/local, xác nhận routing và SSO.
6. Kiểm thử chức năng Agile và dữ liệu.
7. Clean up phần NocoBase cũ nếu không dùng nữa.

## Trạng thái hiện tại

- Nhánh đã tạo: `plane_ce`
- Đã xóa hầu hết artifact NocoBase khỏi repo.
- Đã tạo placeholder `platform/plane-ce/.gitkeep` để giữ cấu trúc.

## Ghi chú

- Tài liệu tham chiếu cũ NocoBase vẫn giữ lại trong `platform/scripts/seed_demo/README.md` dưới dạng legacy.
- Nếu cần, có thể thêm phần migration dữ liệu từ NocoBase sang Plane CE sau khi giải pháp được chốt.
