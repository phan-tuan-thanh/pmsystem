#!/bin/sh
# Deploy a single service from docker-compose.plane.yml
# Usage: deploy-service.sh --service <name> [--with-traefik|--external-traefik] [--detach]
SERVICE=""
WITH_TRAEFIK=0
DETACH="-d"

while [ "$1" != "" ]; do
  case "$1" in
    --service)
      shift; SERVICE="$1";;
    --with-traefik)
      WITH_TRAEFIK=1;;
    --external-traefik)
      WITH_TRAEFIK=0;;
    --no-detach)
      DETACH="";;
    --detach)
      DETACH="-d";;
    -h|--help)
      echo "Usage: $0 --service <name> [--with-traefik|--external-traefik] [--detach]"
      exit 0;;
  esac
  shift
done

if [ -z "$SERVICE" ]; then
  echo "Please provide --service <name>"
  exit 1
fi

COMPOSE_FILES="-f docker-compose.plane.yml"
if [ "$WITH_TRAEFIK" -eq 1 ]; then
  COMPOSE_FILES="$COMPOSE_FILES -f docker-compose.traefik.yml"
fi

echo "Deploying service: $SERVICE"
docker compose $COMPOSE_FILES up $DETACH "$SERVICE"
