# Scripts Update Summary - Phase-Aware Debugging

## 📋 Updates Made

### 1. Enhanced `check.sh` (Main Health Check)

**New Features:**
- ✅ Auto-creates `logs/debug/` directory
- ✅ Clears old debug logs at start of each run
- ✅ Tracks failed containers in array
- ✅ Auto-collects logs for failed/unhealthy containers
- ✅ Saves endpoint error details
- ✅ Shows summary of all failed services
- ✅ Lists where debug logs are saved

**Key Changes:**

```bash
# Old behavior: Just checked status
✅ platform-plane-backend: running
❌ platform-plane-frontend: restarting

# New behavior: Collects logs + shows where saved
❌ platform-plane-frontend: restarting
   📝 Logs saved to: logs/debug/platform-plane-frontend.log

# At end: Lists all failures
⚠️  Failed containers (8):
   • platform-plane-backend
   • platform-plane-frontend
   • ...

📁 Debug logs saved to: logs/debug/
```

**Example Output:**
```
🧹 Cleared old debug logs from logs/debug
🚀 Plane CE Health Check - Phase 1
[...checks...]
⚠️  Failed containers (3):
   • platform-plane-backend
   • platform-plane-frontend
   • endpoint-plane-ce-api

📁 Debug logs saved to: logs/debug/

🔧 Troubleshooting:
  • View debug logs: cat logs/debug/*.log
  • View error details: cat logs/debug/platform-plane-*.log
```

### 2. New `show-debug-logs.sh` (View Debug Logs)

**Purpose:** Easy viewing of collected debug logs

**Usage:**
```bash
# List all available logs
./show-debug-logs.sh

# View specific log
./show-debug-logs.sh platform-plane-backend

# View endpoint error
./show-debug-logs.sh endpoint-plane-ce-api
```

**Features:**
- ✅ Lists all available debug logs with line counts
- ✅ Show specific log contents
- ✅ Error handling for missing logs
- ✅ Formatted output with line separators

### 3. Updated `phase-progress.sh` (Phase Status)

**Already included these features:**
- ✅ Shows current phase
- ✅ Lists all service status
- ✅ Database metrics
- ✅ API health check
- ✅ Completion percentage
- ✅ Next steps for current phase

### 4. New `debug.sh` (Service Debugging)

**Purpose:** Deep-dive debugging for specific services

**Usage:**
```bash
./debug.sh 1                      # Debug Phase 1 all services
./debug.sh 1 backend              # Debug Phase 1 backend
./debug.sh 1 postgres             # Debug Phase 1 database
```

### 5. Script Documentation

**New `scripts/README.md`:**
- ✅ Usage guide for all scripts
- ✅ Phase-specific workflows
- ✅ Common commands
- ✅ Troubleshooting tips

**New `DEBUGGING_GUIDE.md`:**
- ✅ How smart log collection works
- ✅ How to view debug logs
- ✅ Debug workflows
- ✅ Advanced debugging techniques
- ✅ Real-world examples

---

## 🎯 Typical Workflow Now

### Before (Manual)
```bash
$ ./check.sh
❌ platform-plane-backend: running (HEALTH: unhealthy)

$ # Manually figure out what to check
$ docker logs platform-plane-backend
[long output, manually search for errors]
```

### After (Automatic)
```bash
$ ./check.sh
❌ platform-plane-backend: running (HEALTH: unhealthy)
   📝 Logs saved to: logs/debug/platform-plane-backend.log
[check ends]

$ # Logs already collected, just view them
$ ./show-debug-logs.sh platform-plane-backend
[clean formatted output of errors]
```

---

## 📁 Directory Structure

```
platform/
├── scripts/
│   ├── check.sh                    # Health check (updated)
│   ├── phase-progress.sh           # Phase progress (new)
│   ├── debug.sh                    # Service debug (new)
│   ├── show-debug-logs.sh          # View logs (new)
│   ├── logs.sh                     # View live logs
│   ├── up.sh                       # Start services
│   ├── down.sh                     # Stop services
│   └── README.md                   # Script docs (new)
├── logs/
│   └── debug/                      # Auto-created by check.sh
│       ├── platform-postgres.log
│       ├── platform-plane-backend.log
│       └── endpoint-plane-ce-api.log
├── DEBUGGING_GUIDE.md              # Debugging guide (new)
└── SCRIPTS_UPDATE_SUMMARY.md       # This file
```

---

## 🔄 Auto-Log Collection Logic

When `check.sh` runs:

```
1. Create logs/debug/ if not exists
   ↓
2. Clear all *.log files from logs/debug/
   ↓
3. For each container:
   - Check if running
   - Check health status
   - If NOT running OR NOT healthy:
     → Collect full docker logs
     → Save to logs/debug/container.log
     → Show user where saved
   ↓
4. Test all endpoints
   - If endpoint fails:
     → Run curl -v to capture full response
     → Save to logs/debug/endpoint-*.log
   ↓
5. Summary: List all failed containers & log locations
```

---

## 📊 What Gets Logged

### Container Logs
- **Full container output** - Everything sent to stdout/stderr
- **Timestamps** - When each line was output
- **Stack traces** - Full error details
- **Exit codes** - Why container stopped

Example:
```bash
$ cat logs/debug/platform-plane-backend.log
2026-04-25T17:20:15.123456Z Starting Django...
2026-04-25T17:20:16.456789Z Loading database configuration...
2026-04-25T17:20:17.789012Z ERROR: Could not connect to database
psycopg2.OperationalError: could not connect to server
    [stack trace...]
```

### Endpoint Logs
- **HTTP status** - What response code
- **Headers** - Response headers (including redirects)
- **Body** - Full response content
- **Timing** - How long request took

Example:
```bash
$ cat logs/debug/endpoint-plane-ce-api.log
> GET /api/health/ HTTP/1.1
> Host: app.local.test
> User-Agent: curl
>
< HTTP/1.0 404 Not Found
< Content-Type: text/html
< Content-Length: 123
[response body...]
```

---

## 🎓 Example Debugging Session

```bash
# 1. Something's wrong - run health check
$ ./check.sh
⚠️  platform-plane-backend: running (HEALTH: unhealthy)
   📝 Logs saved to: logs/debug/platform-plane-backend.log
❌ Plane CE API: UNREACHABLE (Status: 500)
   📝 Error details saved to: logs/debug/endpoint-plane-ce-api.log

# 2. Check what's wrong with backend
$ ./show-debug-logs.sh platform-plane-backend
📄 Debug Log: platform-plane-backend
═══════════════════════════════════════════════════════════
Traceback (most recent call last):
  File "manage.py", line 22, in <module>
    execute_from_command_line(sys.argv)
ConnectionError: could not connect to database at 'platform-postgres:5432'
═══════════════════════════════════════════════════════════

# 3. Check if postgres is running
$ ./show-debug-logs.sh platform-postgres
✅ Postgres container logs show healthy startup

# 4. Maybe it's a network issue
$ docker exec platform-plane-backend ping -c 1 platform-postgres
PING platform-postgres (172.19.0.2): 56 data bytes
64 bytes from 172.19.0.2: seq=0 ttl=64 time=0.5ms

# 5. Restart backend and check again
$ docker restart platform-plane-backend
$ sleep 10
$ ./check.sh
✅ All services healthy!
```

---

## 💡 Design Principles

The updated scripts follow these principles:

1. **Automatic** - Collect logs without user asking
2. **Non-destructive** - Clear old logs, keep new ones safe
3. **Transparent** - Always show what was collected & where
4. **Organized** - Logs grouped by service in `logs/debug/`
5. **Accessible** - Easy viewing with `show-debug-logs.sh`
6. **Comprehensive** - Captures containers AND endpoints
7. **Phase-aware** - Checks vary by deployment phase

---

## 🚀 Benefits

### Before Update
- ❌ Manual log searching
- ❌ Easy to miss important errors
- ❌ Unclear which services failed
- ❌ Time-consuming debugging

### After Update
- ✅ Auto-collected logs
- ✅ Nothing missed - all failures logged
- ✅ Clear list of what failed
- ✅ Quick debugging with organized logs
- ✅ Perfect for CI/CD integration

---

## 🔗 Integration Points

### With check.sh
```bash
./check.sh                           # Collects logs
./show-debug-logs.sh                 # Views them
cat logs/debug/*.log | grep ERROR    # Searches them
```

### With deployment automation
```bash
#!/bin/bash
./up.sh
./check.sh                           # Auto-logs failures
if [ $? -ne 0 ]; then
    echo "Check failed, logs available at:"
    ls -la logs/debug/
fi
```

### With monitoring
```bash
#!/bin/bash
while true; do
    ./check.sh > /dev/null
    if [ $? -ne 0 ]; then
        # Alert + attach debug logs
        send_alert $(cat logs/debug/*.log)
    fi
    sleep 60
done
```

---

## 📈 Next Steps

### Phase 1 (Current)
- ✅ Scripts are enhanced
- ✅ Debug logs are auto-collected
- ✅ Debugging guide is available
- [ ] Run `./check.sh` regularly
- [ ] Fix any issues using debug logs
- [ ] Sign off when all services healthy

### Phase 2 (Future)
- Use same tools to monitor data seeding
- Track database growth with `check.sh`
- Collect metrics for performance baseline

### Phase 3+ (Future)
- Continue using for ongoing monitoring
- Integrate debug logs into runbooks
- Archive logs for incident analysis

---

**Last Updated**: 2026-04-25  
**Phase**: 1 (Core Infrastructure)  
**Scripts Included**: check.sh, phase-progress.sh, debug.sh, show-debug-logs.sh  
**Status**: ✅ Enhanced debugging system ready for use
