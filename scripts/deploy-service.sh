#!/bin/sh
# Deploy (or restart) a single service without touching the rest of the stack.
# Usage: deploy-service.sh --service <name> [--with-traefik|--external-traefik] [--no-detach]

SERVICE=""
WITH_TRAEFIK=1
DETACH="-d"

while [ "$1" != "" ]; do
  case "$1" in
    --service)        shift; SERVICE="$1";;
    --with-traefik)   WITH_TRAEFIK=1;;
    --external-traefik) WITH_TRAEFIK=0;;
    --no-detach)      DETACH="";;
    --detach)         DETACH="-d";;
    -h|--help)
      echo "Usage: $0 --service <name> [--with-traefik|--external-traefik] [--no-detach]"
      echo "  --service <name>    Service to deploy (e.g. plane-api, plane-worker, plane-minio)"
      echo "  --with-traefik      Include bundled Traefik (default)"
      echo "  --external-traefik  Exclude Traefik from compose context"
      exit 0;;
    *) echo "Unknown option: $1"; exit 1;;
  esac
  shift
done

if [ -z "$SERVICE" ]; then
  echo "❌ Error: --service <name> is required."
  exit 1
fi

COMPOSE_FILES="-f docker-compose.postgres.yml -f docker-compose.redis.yml -f docker-compose.mq.yml -f docker-compose.minio.yml -f docker-compose.plane.yml"
if [ "$WITH_TRAEFIK" -eq 1 ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.traefik.yml"
fi

echo "🔄 Deploying service: $SERVICE (no-deps)"
docker compose $COMPOSE_FILES up --no-deps $DETACH "$SERVICE"
