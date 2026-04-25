# Host Configuration Guide

Hướng dẫn cấu hình hosts cho Plane CE + AI Solution.

## 📋 Tổng Quan

Tất cả các services sử dụng các domain dựa trên biến `DOMAIN` trong `.env`. Mặc định là `local.test`.

## 🔗 Hosts Được Cấu Hình

| Host | Service | Mục Đích |
|------|---------|---------|
| `traefik.local.test` | Traefik | Dashboard giám sát Traefik |
| `auth.local.test` | Authentik | SSO và Identity Management |
| `app.local.test` | Plane CE Frontend | Giao diện chính Plane CE |
| `space.local.test` | Plane CE Space | Chia sẻ công khai |
| `admin.local.test` | Plane CE Admin | Dashboard quản trị Plane CE |
| `ai.local.test` | Plane AI Service | API AI enhancements |

## 🔧 Cấu Hình

### Automatic Setup (Khuyến Khích)

Khi chạy `./scripts/up.sh`, script sẽ tự động:
1. Kiểm tra `/etc/hosts` cho các hosts cần thiết
2. Nếu thiếu, tự động chạy `setup-hosts.sh`
3. Thêm tất cả 6 hosts vào `/etc/hosts`

```bash
cd platform
./scripts/up.sh
```

### Manual Setup

Nếu muốn cấu hình thủ công:

```bash
cd platform
sudo ./scripts/setup-hosts.sh
```

Script sẽ in ra các hosts được thêm:
```
✅ All hostnames have been configured successfully!
You can now access services at:
  - https://traefik.local.test/dashboard/
  - https://auth.local.test
  - https://app.local.test (Plane CE Main)
  - https://space.local.test (Plane CE Public Sharing)
  - https://admin.local.test (Plane CE Admin)
  - https://ai.local.test (Plane AI Service)
```

### Verify Configuration

Kiểm tra xem hosts đã được cấu hình đúng:

```bash
grep "127.0.0.1.*local.test" /etc/hosts
```

Expected output:
```
127.0.0.1 traefik.local.test
127.0.0.1 auth.local.test
127.0.0.1 app.local.test
127.0.0.1 space.local.test
127.0.0.1 admin.local.test
127.0.0.1 ai.local.test
```

## 🌐 Truy Cập Services

### Plane CE Main Application
```
https://app.local.test
Username: admin@plane.local
Password: PlaneAdmin123!
```

### Plane AI Service API
```
https://ai.local.test
Health Check: https://ai.local.test/health/
```

### Plane CE Admin Dashboard
```
https://admin.local.test
```

### Plane CE Public Sharing
```
https://space.local.test
```

### Authentik SSO
```
https://auth.local.test
```

### Traefik Dashboard
```
https://traefik.local.test/dashboard/
```

## 🔐 HTTPS/SSL Notes

- Tất cả services sử dụng HTTPS
- Certificates được tự động tạo bởi Traefik
- Cho development/local, certificates sẽ là self-signed
- Browser có thể warning - điều này là bình thường

Để test với curl, sử dụng `-k` flag:
```bash
curl -k https://app.local.test
```

## 📝 Thay Đổi Domain

Để thay đổi domain (ví dụ: từ `local.test` sang `yourdomain.com`):

1. Edit `.env`:
```bash
DOMAIN=yourdomain.com
```

2. Update `/etc/hosts` hoặc configure DNS:
```bash
127.0.0.1 traefik.yourdomain.com
127.0.0.1 auth.yourdomain.com
127.0.0.1 app.yourdomain.com
127.0.0.1 space.yourdomain.com
127.0.0.1 admin.yourdomain.com
127.0.0.1 ai.yourdomain.com
```

Hoặc chạy:
```bash
sudo ./scripts/setup-hosts.sh
```

3. Restart services:
```bash
./scripts/down.sh
./scripts/up.sh
```

## 🐛 Troubleshooting

### Cannot access services

1. Verify hosts configuration:
```bash
grep "127.0.0.1" /etc/hosts | grep local.test
```

2. Check services are running:
```bash
./scripts/check.sh
```

3. View logs:
```bash
./scripts/logs.sh plane-frontend
```

### DNS not resolving

For macOS users might need to flush DNS cache:
```bash
sudo dscacheutil -flushcache
```

For Linux:
```bash
sudo systemctl restart systemd-resolved
```

### Traefik routing issues

Check Traefik logs:
```bash
./scripts/logs.sh traefik
```

Verify container labels have correct environment variables:
```bash
docker inspect platform-plane-frontend | grep -A5 traefik
```

## 📋 Scripts Tham Liếu

### setup-hosts.sh
Cấu hình tất cả 6 hosts cần thiết cho Plane CE + AI:
- traefik, auth, app, space, admin, ai

```bash
./scripts/setup-hosts.sh
```

### up.sh
Automatic kiểm tra hosts trước khi start services:
- Nếu thiếu hosts, sẽ tự động chạy setup-hosts.sh
- Start tất cả containers

```bash
./scripts/up.sh
```

### check.sh
Verify tất cả services đang chạy và accessible:
- Check container status
- Check database/redis connectivity
- Check web endpoints

```bash
./scripts/check.sh
```

---

**Last Updated**: 2026-04-25  
**Status**: Configured & Verified
