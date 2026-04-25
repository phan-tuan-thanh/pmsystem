#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "Stopping all services in project: $COMPOSE_PROJECT_NAME..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f plane-ai/docker-compose.yml down
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f plane-ce/docker-compose.yml down
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f authentik/docker-compose.yml down
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f traefik/docker-compose.yml down
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f redis/docker-compose.yml down
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f postgres/docker-compose.yml down

echo "All services stopped."
