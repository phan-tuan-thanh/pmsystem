# PostgreSQL Setup & Backup Guide

Tài liệu này hướng dẫn cấu hình và vận hành PostgreSQL service cho Plane CE.

## 1. Cấu hình dịch vụ
PostgreSQL được chạy thông qua `docker-compose.postgres.yml`. Dữ liệu được lưu trữ tại thư mục `./postgres-data/` trên host machine để đảm bảo tính bền vững.

## 2. Chiến lược Backup
- **Công cụ**: `pg_dump` (logical backup)
- **Tần suất**: Hàng ngày (Daily)
- **Retention Policy**: Lưu trữ bản backup trong vòng **7–30 ngày**.

### Lệnh Backup mẫu
Để backup database hiện tại ra file:
```bash
docker exec -t postgres pg_dump -U postgres postgres > backup_$(date +%Y%m%d).sql
```

## 3. Quy trình Restore
Để khôi phục dữ liệu từ một bản backup:
1. Dừng các service đang kết nối tới DB (nếu có).
2. Chạy lệnh:
```bash
cat backup_YYYYMMDD.sql | docker exec -i postgres psql -U postgres postgres
```

## 4. Troubleshooting
- Kiểm tra logs: `docker compose -f docker-compose.postgres.yml logs -f`
- Health check: `pg_isready -U postgres`
