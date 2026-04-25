#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

DEBUG_FILE="debug_report_$(date +"%Y%m%d_%H%M%S").log"

{
    echo "===================================================="
    echo "PLATFORM DEBUG REPORT"
    echo "Timestamp: $(date)"
    echo "Project: $COMPOSE_PROJECT_NAME"
    echo "===================================================="

    echo -e "\n--- [1] SYSTEM INFORMATION ---"
    echo "OS: $(uname -a)"
    echo "Docker Version: $(docker version --format '{{.Server.Version}}' 2>/dev/null)"
    echo "Docker Compose Version: $(docker compose version 2>/dev/null)"

    echo -e "\n--- [2] DIRECTORY STRUCTURE ---"
    ls -R .

    echo -e "\n--- [3] ENVIRONMENT CONFIGURATION (Masked) ---"
    if [ -f .env ]; then
        grep -v "PASSWORD" .env | grep -v "SECRET" | grep -v "KEY"
    else
        echo ".env file not found!"
    fi

    echo -e "\n--- [4] HOSTS MAPPING ---"
    grep "$DOMAIN" /etc/hosts || echo "No mapping for $DOMAIN found in /etc/hosts"

    echo -e "\n--- [5] DOCKER CONTAINER STATUS ---"
    docker ps -a --filter "name=platform-"

    echo -e "\n--- [6] CONTAINER HEALTH HISTORY ---"
    CONTAINERS=$(docker ps -a --filter "name=platform-" --format "{{.Names}}")
    for container in $CONTAINERS; do
        echo -e "\nContainer: $container"
        docker inspect -f 'Status: {{.State.Status}}, Health: {{.State.Health.Status}}, ExitCode: {{.State.ExitCode}}, Error: {{.State.Error}}' "$container" 2>/dev/null
    done

    echo -e "\n--- [7] CONTAINER LOGS (Last 100 lines each) ---"
    for container in $CONTAINERS; do
        echo -e "\n----------------------------------------------------"
        echo "LOGS FOR: $container"
        echo "----------------------------------------------------"
        docker logs --tail 100 "$container" 2>&1
    done

    echo -e "\n--- [8] DOCKER NETWORKS ---"
    docker network ls | grep proxy

} | tee "$DEBUG_FILE"

echo -e "\n===================================================="
echo "Debug report saved to: $PLATFORM_ROOT/$DEBUG_FILE"
echo "===================================================="
