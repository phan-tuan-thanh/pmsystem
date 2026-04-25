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

HOSTS_ENTRY="127.0.0.1 traefik.$DOMAIN auth.$DOMAIN app.$DOMAIN"
ETC_HOSTS="/etc/hosts"

echo "Adding hostnames for $DOMAIN to $ETC_HOSTS..."

# Check if entry already exists
if grep -q "$DOMAIN" "$ETC_HOSTS"; then
    echo "Hostnames for $DOMAIN already exist in $ETC_HOSTS."
else
    echo "Adding $HOSTS_ENTRY to $ETC_HOSTS..."
    echo "$HOSTS_ENTRY" | sudo tee -a "$ETC_HOSTS" > /dev/null
    if [ $? -eq 0 ]; then
        echo "Successfully updated $ETC_HOSTS."
    else
        echo "Failed to update $ETC_HOSTS. Please run with sudo or check permissions."
        exit 1
    fi
fi
