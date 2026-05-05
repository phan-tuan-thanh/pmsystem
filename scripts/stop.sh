#!/bin/sh
# Stop script
# Usage: stop.sh [--service <name>] [--all]

SERVICE=""
ALL=0
ALL_COMPOSE="-f docker-compose.postgres.yml -f docker-compose.redis.yml -f docker-compose.mq.yml -f docker-compose.minio.yml -f docker-compose.plane.yml"

# Include Traefik only if the compose file exists
if [ -f "docker-compose.traefik.yml" ]; then
  ALL_COMPOSE="$ALL_COMPOSE -f docker-compose.traefik.yml"
fi

while [ "$1" != "" ]; do
  case "$1" in
    --service)
      shift; SERVICE="$1";;
    --all)
      ALL=1;;
    -h|--help)
      echo "Usage: $0 [--service <name>] [--all]"
      exit 0;;
  esac
  shift
done

if [ "$ALL" -eq 1 ]; then
  echo "Stopping all services..."
  docker compose $ALL_COMPOSE down
elif [ -n "$SERVICE" ]; then
  echo "Stopping service: $SERVICE"
  docker compose $ALL_COMPOSE stop "$SERVICE"
else
  echo "No service specified. Use --all to stop entire stack or --service <name>."
  exit 1
fi
