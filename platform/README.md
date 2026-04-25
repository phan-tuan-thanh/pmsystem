# Platform Self-Hosted Infrastructure

A production-ready, modular self-hosted platform using Traefik, Authentik, and NocoBase.

## 🚀 Quick Start

### 1. Configuration
Update the `.env` file with your desired domain and secure passwords:
```bash
nano .env
```

### 2. Local DNS Setup (Optional)
If deploying locally on `local.test`, run:
```bash
sudo ./scripts/setup-hosts.sh
```

### 3. Deploy
```bash
./scripts/up.sh
```

### 4. Verify
```bash
./scripts/check.sh
```

---

## 🌐 Accessing Services

| Service | URL | Default Credentials |
| :--- | :--- | :--- |
| **NocoBase** | [https://app.local.test](https://app.local.test) | `admin@nocobase.com` / `nocobase` |
| **Authentik** | [https://auth.local.test](https://auth.local.test) | Setup at [/if/flow/initial-setup/](https://auth.local.test/if/flow/initial-setup/) |
| **Traefik Dash** | [https://traefik.local.test](https://traefik.local.test) | `admin` / `password` |

---

## 🛠 Management Scripts

All scripts are located in the `scripts/` directory and can be run from any folder.

*   `./scripts/up.sh`: Start the entire stack in the correct order.
*   `./scripts/down.sh`: Stop and remove all containers.
*   `./scripts/remove.sh`: PERMANENTLY remove all containers and data volumes.
*   `./scripts/check.sh`: Verify system health and endpoint reachability.
*   `./scripts/logs.sh <app>`: Follow logs for a specific service (e.g., `nocobase`).
*   `./scripts/backup.sh`: Create a timestamped backup of databases and media.
*   `./scripts/debug.sh`: Generate a comprehensive diagnostic report.

---

## 📂 Project Structure

```text
├── .env                 # Central configuration
├── compose.shared.yml   # Shared docker settings
├── scripts/             # Management scripts
├── traefik/             # Reverse Proxy & SSL
├── authentik/           # Identity Provider (SSO)
├── nocobase/            # Business Platform
├── postgres/            # Shared Database
└── redis/               # Shared Cache
```

---

## ❓ Troubleshooting

If any service is unreachable or restarting:
1. Run the debug script: `./scripts/debug.sh`
2. Check the generated `debug_report_*.log`.
3. Ensure your `/etc/hosts` contains the required mappings if working locally.

---

## 🔒 Security Notes
- **Passwords**: Change all default passwords in `.env` before production deployment.
- **SSL**: Let's Encrypt is configured for production. For local development, browsers will show a certificate warning; you can safely proceed or use a local CA.
- **Docker Socket**: Traefik requires access to `/var/run/docker.sock` to discover services.
