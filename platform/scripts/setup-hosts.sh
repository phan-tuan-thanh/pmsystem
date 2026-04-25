#!/bin/bash

# Get the platform root (one level up from scripts/)
PLATFORM_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PLATFORM_ROOT"

# Load domain from .env
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

if [ -z "$DOMAIN" ]; then
    echo "Error: DOMAIN is not set in .env file."
    exit 1
fi

HOSTS_ENTRIES=(
    "127.0.0.1 traefik.$DOMAIN"
    "127.0.0.1 auth.$DOMAIN"
    "127.0.0.1 app.$DOMAIN"
    "127.0.0.1 space.$DOMAIN"
    "127.0.0.1 admin.$DOMAIN"
    "127.0.0.1 ai.$DOMAIN"
)
ETC_HOSTS="/etc/hosts"

echo "Adding hostnames for $DOMAIN to $ETC_HOSTS..."

# Check and add each host entry
ALL_EXISTS=true
for ENTRY in "${HOSTS_ENTRIES[@]}"; do
    HOSTNAME=$(echo $ENTRY | awk '{print $2}')

    if grep -q "^127.0.0.1.*$HOSTNAME" "$ETC_HOSTS"; then
        echo "✓ $HOSTNAME already exists"
    else
        echo "Adding $ENTRY to $ETC_HOSTS..."
        echo "$ENTRY" | sudo tee -a "$ETC_HOSTS" > /dev/null
        if [ $? -eq 0 ]; then
            echo "✓ Successfully added $HOSTNAME"
        else
            echo "✗ Failed to add $HOSTNAME. Please run with sudo or check permissions."
            ALL_EXISTS=false
        fi
    fi
done

if [ "$ALL_EXISTS" = true ]; then
    echo ""
    echo "✅ All hostnames have been configured successfully!"
    echo "You can now access services at:"
    echo "  - https://traefik.$DOMAIN/dashboard/"
    echo "  - https://auth.$DOMAIN"
    echo "  - https://app.$DOMAIN (Plane CE Main)"
    echo "  - https://space.$DOMAIN (Plane CE Public Sharing)"
    echo "  - https://admin.$DOMAIN (Plane CE Admin)"
    echo "  - https://ai.$DOMAIN (Plane AI Service)"
else
    echo ""
    echo "⚠️  Some hostnames could not be added. Please check permissions."
    exit 1
fi
