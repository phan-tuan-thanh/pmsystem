#!/bin/bash

# Show debug logs from check.sh failures
# Usage: ./show-debug-logs.sh [container_name]

PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

DEBUG_DIR="logs/debug"

if [ ! -d "$DEBUG_DIR" ]; then
    echo "❌ No debug logs directory found: $DEBUG_DIR"
    echo ""
    echo "Run check.sh first to generate debug logs:"
    echo "  ./check.sh"
    exit 1
fi

echo "╔════════════════════════════════════════════════════════════╗"
echo "║           Plane CE Debug Logs Viewer                      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Count logs
LOG_COUNT=$(find "$DEBUG_DIR" -name "*.log" -type f | wc -l)

if [ $LOG_COUNT -eq 0 ]; then
    echo "✅ No debug logs - All services are healthy!"
    exit 0
fi

echo "📁 Found $LOG_COUNT debug log(s) in $DEBUG_DIR/"
echo ""

if [ -z "$1" ]; then
    # List all logs
    echo "Available logs:"
    echo "─────────────"
    find "$DEBUG_DIR" -name "*.log" -type f -exec basename {} \; | while read log; do
        size=$(wc -l < "$DEBUG_DIR/$log" 2>/dev/null || echo 0)
        echo "  📄 $log ($size lines)"
    done
    echo ""
    echo "View specific log:"
    echo "  ./show-debug-logs.sh <log_name>"
    echo ""
    echo "Examples:"
    echo "  ./show-debug-logs.sh platform-postgres"
    echo "  ./show-debug-logs.sh platform-plane-backend"
else
    # Show specific log
    LOG_FILE="$DEBUG_DIR/$1.log"
    if [ ! -f "$LOG_FILE" ]; then
        # Try with .log extension
        if [ ! -f "$LOG_FILE" ]; then
            echo "❌ Log file not found: $LOG_FILE"
            echo ""
            echo "Available logs:"
            find "$DEBUG_DIR" -name "*.log" -type f -exec basename {} \; | sed 's/.log$//'
            exit 1
        fi
    fi

    echo "📄 Debug Log: $1"
    echo "═══════════════════════════════════════════════════════════"
    cat "$LOG_FILE"
    echo "═══════════════════════════════════════════════════════════"
fi
