# 🚀 Plane CE Quick Reference - Updated Scripts

## Health Check (Auto-Collects Logs)

```bash
# Run health check - automatically collects debug logs
./check.sh

# Output shows:
# 🧹 Cleared old debug logs
# ✅ Healthy services
# ❌ Failed services (with log locations)
# 📁 Debug logs saved to: logs/debug/
```

## View Debug Logs

```bash
# List all logs
./show-debug-logs.sh

# View specific log
./show-debug-logs.sh platform-plane-backend
./show-debug-logs.sh endpoint-plane-ce-api

# Raw view
cat logs/debug/*.log
grep ERROR logs/debug/*.log
```

## Phase Progress

```bash
# Show current phase status
./phase-progress.sh

# Verbose output with all services
./phase-progress.sh -v
```

## Detailed Debugging

```bash
# Debug specific service
./debug.sh 1 backend
./debug.sh 1 postgres

# Real-time logs
docker logs -f platform-plane-backend
```

## Service Management

```bash
# Start all services
./up.sh

# Stop all services
./down.sh

# Restart services
docker restart platform-plane-backend

# Check status
./check.sh
```

## Common Issues

**Backend not responding?**
```bash
./check.sh                                    # See logs
./show-debug-logs.sh platform-plane-backend   # View error
```

**Database not ready?**
```bash
./show-debug-logs.sh platform-postgres        # Check DB logs
docker exec platform-postgres pg_isready      # Test connectivity
```

**Frontend blank?**
```bash
./show-debug-logs.sh endpoint-plane-ce-api    # Check API response
docker logs platform-plane-frontend           # Check frontend logs
```

## Workflow

```bash
1. Run health check     → ./check.sh
2. Review failures      → ./show-debug-logs.sh
3. Check specific log   → ./show-debug-logs.sh <service>
4. Fix issue            → (restart/redeploy)
5. Re-check            → ./check.sh
```

## Documentation

- `DEBUGGING_GUIDE.md` - Full debugging guide
- `SCRIPTS_UPDATE_SUMMARY.md` - What changed
- `scripts/README.md` - All scripts explained
- `PHASE_1_COMPLETION.md` - Phase 1 details
- `DEPLOYMENT_PLAN.md` - 5-phase plan

---

**Key Feature**: Auto-collects logs on every `./check.sh` run!
