#!/bin/bash
ALIAS="$1"
AUTH_FILE="$2"
DEFAULT="$3"
if [ $DEFAULT == 'SetAsDefaultDEVHUB' ]; then
DEFAULT="--set-default-dev-hub"
else
DEFAULT="--set-default"
fi
set -e
# Authenticate with your target org
sf org login sfdx-url --sfdx-url-file $AUTH_FILE --alias $ALIAS $DEFAULT

# Check authentication status
sf org list