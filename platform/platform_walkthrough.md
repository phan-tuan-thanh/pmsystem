# Self-Hosted Platform Walkthrough

This project provides a production-ready, modular self-hosted infrastructure using Traefik as a reverse proxy, Authentik for identity management, and NocoBase as the business platform.

## Project Structure

```text
/platform/
├── .env                        # Centralized environment variables
├── compose.shared.yml          # Reusable compose configurations
├── scripts/                    # Management scripts
│   ├── up.sh                   # Deployment script
│   ├── down.sh                 # Stop script
│   ├── logs.sh                 # Log viewer
│   ├── backup.sh               # Backup script
│   ├── setup-hosts.sh          # Local DNS setup (/etc/hosts)
│   ├── check.sh                # Health check script
│   └── debug.sh                # One-click debug report collector
├── traefik/
│   ├── docker-compose.yml
│   ├── dynamic/                # Dynamic configurations
│   └── letsencrypt/            # SSL Certificates (acme.json)
├── postgres/
│   ├── docker-compose.yml
│   └── init-db.sql             # Database initialization script
├── redis/
│   └── docker-compose.yml
├── authentik/
│   ├── docker-compose.yml
│   └── media/                  # Authentik media files
└── nocobase/
    ├── docker-compose.yml
    └── data/                   # NocoBase application data
```

## Key Features

1.  **Modular Design**: Each service has its own `docker-compose.yml`, making it easy to manage and update independently.
2.  **Centralized Configuration**: All important variables are in a single `.env` file.
3.  **Automatic SSL**: Traefik handles HTTPS automatically using Let's Encrypt.
4.  **Shared Infrastructure**: Postgres and Redis are shared across applications for efficiency.
5.  **High Security**: Traefik dashboard is protected by Basic Auth, and services use a dedicated `proxy` network.
6.  **Healthchecks**: All services include healthchecks to ensure correct startup order.

## Deployment Instructions

### 1. Configure Environment Variables
Open `platform/.env` and update the following:
- `DOMAIN`: Your base domain (e.g., `local.test` for local or `mydomain.com` for production).
- `TRAEFIK_EMAIL`: Your email for Let's Encrypt notifications.
- `Passwords`: Replace all placeholder passwords with strong, unique strings.

### 2. Deploy the Stack
You can run the deployment script from any directory:
```bash
./platform/scripts/up.sh
```
*Note: If you are using `local.test`, the script will automatically check and ask for your password to update `/etc/hosts` if needed. The scripts are now path-independent and can be executed from the project root or from within the `scripts/` folder.*

### 3. Verify Deployment
Once the deployment is complete, run the health check script to ensure everything is running correctly:
```bash
./platform/scripts/check.sh
```

### 4. Access Services
You can access the following services:
- **Traefik Dashboard**: `http://traefik.local.test` (or `https://traefik.yourdomain.com`)
- **Authentik**: `http://auth.local.test` (or `https://auth.yourdomain.com`)
- **NocoBase**: `http://app.local.test` (or `https://app.yourdomain.com`)

## Management Commands

### View Logs
To follow logs for a specific application:
```bash
./scripts/logs.sh authentik
```

### Stop All Services
```bash
./scripts/down.sh
```

### Backup Data
To perform a full backup of databases and media:
```bash
./scripts/backup.sh
```

## Troubleshooting

If you encounter issues (e.g., containers restarting), use the debug script to collect all relevant information in one go:

```bash
./platform/scripts/debug.sh
```

This script will generate a `debug_report_TIMESTAMP.log` containing:
- Container statuses and health history.
- Last 100 lines of logs for every service.
- Masked environment configuration.
- Directory structure and network status.

Provide this log to your support agent or use it for self-diagnosis.
