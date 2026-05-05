# Deployment docs

This document describes the deployment scripts and checks.

Scripts (location: scripts/):
- deploy.sh: bring up the stack. Supports --with-traefik or --external-traefik, --env, --detach/--no-detach.
- stop.sh: stop a service or the whole stack (--service, --all).
- deploy-service.sh: deploy a single service from docker-compose.plane.yml.
- check.sh: pre-deploy checks (docker availability, compose files, optional Traefik reachability).

Recommendations:
- Make scripts executable: chmod +x scripts/*.sh
- Use --with-traefik for local testing when you want Traefik bundled with the project.
- For production in environments with central Traefik, use --external-traefik and ensure labels/entrypoints are configured in docker-compose.plane.yml.

Example flows:
1) Fresh single-node deployment with bundled Traefik:
   ./scripts/check.sh
   ./scripts/deploy.sh --with-traefik --env production

2) Deploy only backend with external Traefik:
   ./scripts/check.sh --traefik-url https://traefik.example.com
   ./scripts/deploy-service.sh --service plane-api --external-traefik
