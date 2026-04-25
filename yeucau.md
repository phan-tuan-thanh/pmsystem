Mục tiêu

Thiết kế cấu trúc hạ tầng self-hosted với các yêu cầu:

Dùng Traefik làm reverse proxy + SSL + routing
Dùng Authentik làm SSO / Identity Provider
Dùng NocoBase là ứng dụng business platform
Mỗi ứng dụng có compose file riêng
Các cấu hình chung dùng lại để dễ quản lý
Dễ thêm app mới sau này
Dễ backup / migrate / CI-CD

Cấu trúc file theo chuẩn production-lite cho Linux server Ubuntu.

Kiến trúc mong muốn
/opt/platform/
│── .env
│── compose.shared.yml
│── networks/
│── traefik/
│   ├── docker-compose.yml
│   ├── dynamic/
│   └── letsencrypt/
│
│── authentik/
│   ├── docker-compose.yml
│   └── media/
│
│── nocobase/
│   ├── docker-compose.yml
│   └── data/
│
│── postgres/
│   └── docker-compose.yml
│
│── redis/
│   └── docker-compose.yml
│
└── scripts/
    ├── up.sh
    ├── down.sh
    ├── restart.sh
    └── backup.sh
Nguyên tắc thiết kế
1. Mỗi ứng dụng compose riêng

Ví dụ:

traefik/docker-compose.yml
authentik/docker-compose.yml
nocobase/docker-compose.yml

Để deploy riêng lẻ:

docker compose -f traefik/docker-compose.yml up -d
docker compose -f authentik/docker-compose.yml up -d
2. Có file cấu hình dùng chung

Sinh file:

compose.shared.yml

Chứa:

network external chung
logging config
restart policy
timezone
common labels

Ví dụ:

x-common: &common
  restart: unless-stopped
  env_file:
    - ../.env
  networks:
    - proxy

networks:
  proxy:
    external: true
3. File .env trung tâm

Sinh file:

/opt/platform/.env

Ví dụ:

DOMAIN=example.com
TZ=Asia/Ho_Chi_Minh

POSTGRES_PASSWORD=StrongPass123
AUTHENTIK_SECRET_KEY=change_me
AUTHENTIK_ERROR_REPORTING__ENABLED=false

TRAEFIK_EMAIL=admin@example.com
Chi tiết từng service
A. Traefik
Yêu cầu agent sinh compose:
Dashboard bật auth
HTTP -> HTTPS redirect
Let's Encrypt
Docker provider
File provider dynamic config
Domain:
traefik.example.com
Volume:
/var/run/docker.sock
./dynamic
./letsencrypt
B. Postgres dùng chung

1 container postgres phục vụ:

authentik DB
nocobase DB

Yêu cầu tạo nhiều DB init script:

authentik
nocobase
C. Redis dùng chung

Redis phục vụ:

authentik worker/cache
D. Authentik

Domain:

auth.example.com

Yêu cầu:

server
worker
dùng postgres
dùng redis
persist media
E. NocoBase

Domain:

app.example.com

Yêu cầu:

dùng postgres riêng DB nocobase
sau này tích hợp SSO qua Authentik
Routing yêu cầu Traefik labels

Mỗi compose phải có labels chuẩn:

traefik.enable=true
traefik.http.routers.xxx.rule=Host(`...`)
traefik.http.routers.xxx.entrypoints=websecure
traefik.http.routers.xxx.tls.certresolver=letsencrypt
Scripts quản lý cần sinh
up.sh

Khởi động toàn bộ đúng thứ tự:

postgres
redis
traefik
authentik
nocobase
down.sh

Stop toàn bộ

logs.sh

Theo dõi logs theo app:

./logs.sh traefik
./logs.sh authentik
backup.sh

Backup:

postgres dump
volume media
nocobase data
Yêu cầu output của agent
Sinh đầy đủ:
File tree
Nội dung từng file:
.env
compose.shared.yml
traefik/docker-compose.yml
postgres/docker-compose.yml
redis/docker-compose.yml
authentik/docker-compose.yml
nocobase/docker-compose.yml
scripts/*.sh
Kèm hướng dẫn deploy:
docker network create proxy
chmod +x scripts/*.sh
./scripts/up.sh
Yêu cầu tối ưu thêm

Agent cần áp dụng best practice:

healthcheck
depends_on
named volume
external network
least privilege
no hardcode password
bind mount tối thiểu
restart policy
Nếu được thì sinh thêm bản nâng cao
Option A

Multi server deploy

Option B

Backup lên S3

Option C

Authentik protect Traefik dashboard

Yêu cầu: Hãy tạo full project production-ready theo spec trên.
Output từng file riêng biệt, có markdown code block cho từng file.
Không rút gọn.

