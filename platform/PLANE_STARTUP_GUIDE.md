# Plane CE Startup Guide - Troubleshooting & Solutions

## Tình Hình Hiện Tại

✅ **Services Running:**
- PostgreSQL (database)
- Redis (cache)
- Traefik (reverse proxy)
- Authentik (SSO)
- Plane AI Service

❌ **Services Restarting:**
- Plane Backend
- Plane Frontend  
- Plane Worker
- Plane Beat
- Plane Live
- Plane Admin
- Plane Space

## Vấn Đề

Plane CE official Docker images cần:
1. **Database migrations** - Setup schema ban đầu
2. **Initial admin user** - Tạo tài khoản admin
3. **Configuration** - Setup services đúng cách

Hiện tại chúng ta không có initialization steps này.

## Giải Pháp - Cách 1: Dùng Plane CE Official Docker Compose (Khuyến Khích)

Plane CE cung cấp docker-compose.yml chính thức với tất cả initialization steps.

### Bước 1: Clone Plane CE repo

```bash
cd /tmp
git clone https://github.com/makeplane/plane.git
cd plane
git checkout stable  # Hoặc latest version
```

### Bước 2: Reference chính thức docker-compose

Sao chép hoặc tham khảo:
- `docker/production.yml` - Production setup
- `docker/dev.yml` - Development setup

### Bước 3: Adapt cho platform architecture

Copy relevant services từ official repo và adapt:
- Thay thế image tags
- Config environment variables
- Setup database initialization

## Giải Pháp - Cách 2: Kích Hoạt Manual Initialization

Nếu muốn giữ current setup:

### Bước 1: Tạo initialization container

```bash
# Chạy một lần để setup database
docker compose -p platform --env-file .env \
  -f postgres/docker-compose.yml \
  -f plane-ce/docker-compose.yml \
  run -rm plane-backend \
  python manage.py migrate --noinput
```

### Bước 2: Tạo admin user

```bash
docker compose -p platform --env-file .env \
  -f postgres/docker-compose.yml \
  -f plane-ce/docker-compose.yml \
  run -rm plane-backend \
  python manage.py shell -c \
  "from django.contrib.auth.models import User; User.objects.create_superuser('admin@plane.local', 'admin@plane.local', 'PlaneAdmin123!')"
```

### Bước 3: Restart services

```bash
docker compose -p platform --env-file .env -f plane-ce/docker-compose.yml restart
```

## Giải Pháp - Cách 3: Sử Dụng Plane's Docker Images Khác

Plane cung cấp pre-built images với initialize scripts. Cần update:

1. Image tags - Sử dụng các image có init scripts built-in
2. Entry points - Correct entry points từ official docs  
3. Environment - Thêm các env vars cần thiết

## Tiếp Theo Để Làm

### Ngay Lập Tức (Urgent)

1. **Xác định Plane CE version** - Kiểm tra docs:
   - https://github.com/makeplane/plane
   - https://docs.plane.so

2. **Lấy docker-compose.yml chính thức** từ Plane repo

3. **Adapt nó cho architecture của bạn** - Merge với Traefik/Authentik setup

### Thay Thế (Alternative)

Nếu muốn tạo initialization scripts riêng:

```bash
# platform/scripts/init-plane.sh
#!/bin/bash

echo "Initializing Plane CE database..."
docker compose -p platform --env-file .env \
  run -rm plane-backend \
  python manage.py migrate

echo "Creating superuser..."
docker compose -p platform --env-file .env \
  run -rm plane-backend \
  python manage.py createsuperuser \
    --noinput \
    --username admin \
    --email admin@plane.local

echo "Collecting static files..."
docker compose -p platform --env-file .env \
  run -rm plane-backend \
  python manage.py collectstatic --noinput

echo "Plane CE initialized!"
```

Sau đó chạy:
```bash
chmod +x platform/scripts/init-plane.sh
./scripts/init-plane.sh
```

## Trạng Thái Hiện Tại

### Những Gì Hoạt Động

✅ Infrastructure setup (Postgres, Redis, Traefik, Authentik)
✅ Docker images pulled successfully
✅ Network configuration correct  
✅ Host configuration setup
✅ AI service running

### Những Gì Cần Khắc Phục

❌ Plane CE initialization
❌ Database schema setup
❌ Admin user creation
❌ Service startup scripts

## Commit Đã Tạo

- ✅ Implemented Plane CE + AI Solution
- ✅ Updated host configuration
- ✅ Fixed docker-compose dependencies
- ✅ Removed invalid command overrides
- ⏳ Need: Plane CE initialization

## Khuyến Cáo

**Dùng Plane CE's official docker-compose setup** là cách tốt nhất vì:
1. Được Plane team maintain
2. Có tất cả initialization scripts
3. Tested và stable
4. Dễ update theo versions mới

## Tài Liệu Tham Khảo

- Plane CE GitHub: https://github.com/makeplane/plane
- Official Docs: https://docs.plane.so  
- Docker Compose Docs: https://github.com/makeplane/plane/tree/main/docker
- Issue Tracker: https://github.com/makeplane/plane/issues

---

**Next Action**: Lấy docker-compose.yml chính thức từ Plane repo hoặc tạo initialization scripts
