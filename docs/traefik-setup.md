# Traefik Setup

Tài liệu này hướng dẫn cấu hình Traefik v3 làm Reverse Proxy cho hệ thống Plane CE.

## 1. Cấu hình Entrypoints

- **Web (Port 80)**: Tự động chuyển hướng (redirect) sang Websecure (Port 443).
- **Websecure (Port 443)**: Cổng chính cho HTTPS.

## 2. Quy tắc Định tuyến (Routing)

Sử dụng Traefik Labels trong `docker-compose.plane.yml`:

- **Frontend**: `Host(`${PLANE_DOMAIN}`)`
- **API**: `Host(`${PLANE_DOMAIN}`) && PathPrefix(`/api`)`
- **Space**: `Host(`${PLANE_DOMAIN}`) && PathPrefix(`/space`)`

## 3. Quản lý SSL/TLS

Hệ thống hỗ trợ 2 chế độ:

### A. Chế độ Tự cấp phát (Self-signed)
Mặc định cho môi trường Staging/Dev. Trình duyệt sẽ hiển thị cảnh báo bảo mật.

### B. Let's Encrypt (Production)
Cấu hình trong `docker-compose.traefik.yml` qua `certificatesresolvers`:
- `SSL_EMAIL`: Email đăng ký với Let's Encrypt.
- `./traefik/acme.json`: Nơi lưu trữ certificate (cần phân quyền 600).

## 4. Docker Socket
Traefik cần truy cập `/var/run/docker.sock` để tự động phát hiện các service mới qua Labels.
**Lưu ý**: Chỉ mount ở chế độ Read-only (`ro`).
