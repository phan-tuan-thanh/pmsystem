# Plane CE Debugging & Log Collection Guide

## 🔍 Smart Log Collection with check.sh

The updated `check.sh` script now automatically collects debug logs when services fail.

### How It Works

1. **Clears old logs** - Every run of `check.sh` deletes old debug logs from `logs/debug/`
2. **Checks all services** - Verifies containers are running and healthy
3. **Auto-collects logs** - For any failed/unhealthy container, saves full logs
4. **Saves endpoint errors** - When web endpoints fail, saves detailed response logs
5. **Shows summary** - Lists all failed containers and where logs are saved

### Usage

```bash
# Run health check (automatically collects debug logs)
./check.sh

# Output shows:
# 🧹 Cleared old debug logs from logs/debug
# ⚠️  platform-plane-backend: running (HEALTH: unhealthy)
#    📝 Logs saved to: logs/debug/platform-plane-backend.log
```

## 📁 Debug Log Structure

```
platform/
└── logs/
    └── debug/
        ├── platform-postgres.log              # DB container logs
        ├── platform-redis.log                 # Cache container logs
        ├── platform-plane-backend.log         # Backend API logs
        ├── platform-plane-worker.log          # Worker logs
        ├── platform-plane-frontend.log        # Frontend logs
        ├── endpoint-plane-ce.log              # Frontend endpoint error
        ├── endpoint-plane-ce-api.log          # API endpoint error
        └── endpoint-authentik-login.log       # Auth endpoint error
```

## 🎯 Viewing Debug Logs

### View all available logs

```bash
./show-debug-logs.sh
```

**Output:**
```
Found 8 debug log(s) in logs/debug/

Available logs:
─────────────
  📄 platform-postgres.log (45 lines)
  📄 platform-plane-backend.log (124 lines)
  📄 platform-plane-worker.log (312 lines)
  📄 endpoint-plane-ce.log (38 lines)
```

### View specific log

```bash
./show-debug-logs.sh platform-plane-backend
./show-debug-logs.sh endpoint-plane-ce-api
```

### View raw logs

```bash
# View all debug logs at once
cat logs/debug/*.log

# View specific service
cat logs/debug/platform-plane-backend.log

# Follow logs in real-time
tail -f logs/debug/platform-plane-backend.log

# Search for errors
grep ERROR logs/debug/*.log
grep -i "failed" logs/debug/*.log
```

## 🔄 Typical Debugging Workflow

### 1. Run Health Check
```bash
./check.sh
```

### 2. Review Debug Logs
```bash
# View failed containers
./show-debug-logs.sh

# Check backend errors
./show-debug-logs.sh platform-plane-backend

# Check API endpoint error
./show-debug-logs.sh endpoint-plane-ce-api
```

### 3. Identify Root Cause

Common issues to look for in logs:

**Database Connection Errors:**
```
psycopg2.OperationalError: could not connect to server
```
Solution: Check `platform-postgres` logs and ensure DB is running

**Port Already in Use:**
```
Address already in use: ('0.0.0.0', 8000)
```
Solution: Check what's using the port or restart services

**Migration Failures:**
```
django.db.migrations.exceptions.MigrationError
```
Solution: Check `logs/debug/platform-plane-backend.log` for migration details

**Redis Connection:**
```
ConnectionError: Error 111 connecting to localhost:6379
```
Solution: Check `platform-redis` is running

### 4. Restart & Verify

```bash
# Restart failing service
docker compose -p platform restart platform-plane-backend

# Re-run health check
./check.sh

# Check new logs (old ones were cleared)
./show-debug-logs.sh platform-plane-backend
```

## 📊 Debug Information Collected

### For Failed Containers

- **Full container logs** - Everything the service output
- **Timestamps** - When errors occurred
- **Stack traces** - Full error details
- **Environment** - Configuration context

### For Failed Endpoints

- **HTTP response** - Headers and status
- **Redirect chains** - Where request ended up
- **Error messages** - Detailed response body
- **Connection info** - Host, port, SSL details

## 🎯 Phase-Specific Debugging

### Phase 1 (Core Infrastructure)

**Key containers to watch:**
```bash
# Database
./show-debug-logs.sh platform-postgres

# Cache
./show-debug-logs.sh platform-redis

# Backend API
./show-debug-logs.sh platform-plane-backend

# API endpoint
./show-debug-logs.sh endpoint-plane-ce-api
```

**Common Phase 1 issues:**
1. PostgreSQL not ready
2. Migrations not completed
3. Backend can't connect to DB
4. API endpoints returning 404/500

## 📈 Monitoring During Deployment

Create a monitoring loop during deployment:

```bash
#!/bin/bash
while true; do
    clear
    ./check.sh
    echo ""
    echo "Last update: $(date)"
    echo "Next check in 30 seconds... (Ctrl+C to stop)"
    sleep 30
done
```

Or use the phase-progress script:

```bash
./phase-progress.sh
```

## 🔧 Advanced Debugging

### Real-time Logs

```bash
# Follow backend logs in real-time
docker logs -f platform-plane-backend

# Follow with timestamps
docker logs -f --timestamps platform-plane-backend

# Last 100 lines
docker logs --tail 100 platform-plane-backend
```

### Interactive Debugging

```bash
# Connect to running container
docker exec -it platform-plane-backend /bin/bash

# Check database from container
docker exec platform-postgres psql -U plane_ce -d plane_ce -c "SELECT * FROM accounts_user;"

# Check Redis from container
docker exec platform-redis redis-cli ping
```

### Log Analysis

```bash
# Count errors in backend
grep -c ERROR logs/debug/platform-plane-backend.log

# Find warning messages
grep WARN logs/debug/*.log

# Extract timestamps of failures
grep -i "error\|failed" logs/debug/*.log | grep timestamp

# Get last error in each service
for f in logs/debug/platform-*.log; do
    echo "=== $(basename $f) ==="
    tail -5 "$f"
done
```

## 📋 Auto-Generated Debug Info

When `check.sh` runs, it automatically generates:

1. **Container Status** - Is it running?
2. **Health Status** - Is it healthy?
3. **Full Logs** - Last 100+ lines from container
4. **Connectivity Tests** - Can we reach it?
5. **API Responses** - What's the service returning?

**No manual log collection needed** - Just run `./check.sh` and review logs in `logs/debug/`

## 🎓 Example Debug Session

```bash
# 1. Run health check
$ ./check.sh
❌ System Status: DEGRADED
⚠️  Failed containers (3):
   • platform-plane-backend
   • platform-plane-frontend
   • endpoint-plane-ce-api
📁 Debug logs saved to: logs/debug/

# 2. View backend error
$ ./show-debug-logs.sh platform-plane-backend
📄 Debug Log: platform-plane-backend
═══════════════════════════════════════════════════════════
Traceback (most recent call last):
  File "manage.py", line 22, in <module>
    execute_from_command_line(sys.argv)
ConnectionError: could not connect to database
═══════════════════════════════════════════════════════════

# 3. Check database
$ ./show-debug-logs.sh platform-postgres
✅ PostgreSQL is ready

# 4. Restart backend
$ docker restart platform-plane-backend

# 5. Re-check
$ ./check.sh
✅ System Status: OPERATIONAL
```

## 📚 Related Scripts

- `./check.sh` - Health check (collects debug logs)
- `./show-debug-logs.sh` - View collected logs
- `./phase-progress.sh` - Track deployment progress
- `./debug.sh` - Detailed service debugging
- `./logs.sh` - Tail service logs in real-time

## 🚀 Quick Commands

```bash
# Full diagnostic
./check.sh

# View failures
./show-debug-logs.sh

# Check specific service
./show-debug-logs.sh platform-plane-backend

# Real-time monitoring
docker logs -f platform-plane-backend

# Restart & verify
docker restart platform-plane-backend && ./check.sh

# All errors in one view
grep ERROR logs/debug/*.log
```

## 💡 Pro Tips

1. **Always run `./check.sh` first** - It auto-collects all logs
2. **Logs are cleared each run** - Only current issues remain
3. **Keep debug logs for analysis** - Archive before clearing if needed
4. **Use grep to search logs** - `grep ERROR logs/debug/*.log`
5. **Follow real-time** - `docker logs -f <container>`
6. **Check phase progress** - `./phase-progress.sh` shows overall status

---

**Last Updated**: 2026-04-25  
**Phase**: 1 (Core Infrastructure)  
**Status**: Enhanced debugging in place
