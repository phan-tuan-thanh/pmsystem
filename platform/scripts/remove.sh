#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load environment variables
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

echo "⚠️  WARNING: This will PERMANENTLY DELETE all containers and DATA VOLUMES for project: $COMPOSE_PROJECT_NAME"
read -p "Are you sure you want to proceed? (y/N): " confirm

if [[ $confirm != [yY] && $confirm != [yY][eE][sS] ]]; then
    echo "Operation cancelled."
    exit 0
fi

echo "Removing all services and volumes..."
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f nocobase/docker-compose.yml down -v
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f authentik/docker-compose.yml down -v
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f traefik/docker-compose.yml down -v
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f redis/docker-compose.yml down -v
docker compose -p $COMPOSE_PROJECT_NAME --env-file .env -f postgres/docker-compose.yml down -v

# Remove any remaining named volumes for this project
docker volume ls --filter name=${COMPOSE_PROJECT_NAME} -q | xargs -r docker volume rm

echo "Cleanup complete. All containers and persistent volumes have been removed."
