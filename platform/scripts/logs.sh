#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    set -a; source .env; set +a
fi

APP=$1

if [ -z "$APP" ]; then
    echo "Usage: ./logs.sh <app_name>"
    echo "Available apps: postgres, redis, traefik, authentik, plane-backend, plane-worker, plane-beat, plane-frontend, plane-space, plane-admin, plane-live, plane-ai"
    exit 1
fi

case $APP in
    postgres|redis|traefik|authentik)
        docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f $APP/docker-compose.yml logs -f
        ;;
    plane-backend|plane-worker|plane-beat|plane-frontend|plane-space|plane-admin|plane-live)
        docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f plane-ce/docker-compose.yml logs -f $APP
        ;;
    plane-ai)
        docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f plane-ai/docker-compose.yml logs -f
        ;;
    *)
        echo "Unknown app: $APP"
        exit 1
        ;;
esac
