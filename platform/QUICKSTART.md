# Step-by-Step Deployment & Initial Login Guide

Follow these steps to deploy the platform on your local machine and perform your first login.

## Step 1: Prepare the Environment
Ensure you have **Docker** and **Docker Compose** installed on your system.

1. Open your terminal.
2. Navigate to the project directory:
   ```bash
   cd platform
   ```

## Step 2: Configuration
Open the `.env` file to review the settings. By default, it is configured for `local.test`.
```bash
# You can leave these as defaults for local testing
DOMAIN=local.test
COMPOSE_PROJECT_NAME=platform
```

## Step 3: Map Hostnames (Required for Local Dev)
Since we are using custom domains (`local.test`), you must map them to your local IP address.
Run the automated setup script (it will ask for your computer's password):
```bash
sudo ./scripts/setup-hosts.sh
```

## Step 4: Deploy the System
Start all services in the correct sequence. The script will wait for the database and cache to be ready before starting the applications.
```bash
./scripts/up.sh
```
*Wait until you see "Deployment complete!"*

## Step 5: Verify Everything is Working
Run the health check script to ensure containers are healthy and web endpoints are reachable:
```bash
./scripts/check.sh
```
*All checks should show a green ✅.*

---

## Step 6: Initial Login (The First Time)

### 1. Setup Authentik (Identity Provider)
Authentik requires a one-time initial setup to create the administrator account.
1. Open your browser and go to: **[https://auth.local.test/if/flow/initial-setup/](https://auth.local.test/if/flow/initial-setup/)**
2. Follow the on-screen instructions to set a password for the `akadmin` user.
3. This account will be your master "Identity" login.

### 2. Login to Plane CE (Business Platform)
Plane CE sử dụng tài khoản được cấu hình trong file `.env` (các biến `PLANE_CE_ADMIN_EMAIL` và `PLANE_CE_ADMIN_PASSWORD`).
1. Go to: **[https://app.local.test](https://app.local.test)**
2. Enter the default credentials:
   - **Email**: `admin@planece.com` *(configured in `.env` → `PLANE_CE_ADMIN_EMAIL`)*
   - **Password**: `planece` *(configured in `.env` → `PLANE_CE_ADMIN_PASSWORD`)*
3. Once logged in, go to **Profile Settings** and change your password immediately.
4. Also update `PLANE_CE_ADMIN_PASSWORD` in `.env` to match.

### 3. View Traefik Dashboard (Infrastructure Monitor)
To see how your traffic is being routed:
1. Go to: **[https://traefik.local.test/dashboard/](https://traefik.local.test/dashboard/)**
2. When prompted for credentials, use:
   - **Username**: `admin`
   - **Password**: `password`

---

## 🛠 Useful Commands for Daily Use
- **Stop everything**: `./scripts/down.sh`
- **Wipe everything (Delete data)**: `./scripts/remove.sh`
- **Start everything**: `./scripts/up.sh`
- **Check status**: `./scripts/check.sh`
- **View logs**: `./scripts/logs.sh plane-ce`
- **Create backup**: `./scripts/backup.sh`
