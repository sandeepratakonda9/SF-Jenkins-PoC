#!/bin/bash
CLIENTID="$1"
CI_USER="$2"
ALIAS="$3"
SERVER_KEY_FILE="$4"
INSTANCE_URL="$5"
DEFAULT="$6"
if [ $DEFAULT == 'SetAsDefaultDEVHUB' ]; then
DEFAULT="--set-default-dev-hub"
else
DEFAULT="--set-default"
fi
set -e
# Authenticate with your target org
sf org login jwt --client-id $CLIENTID --username $CI_USER --alias $ALIAS --jwt-key-file $SERVER_KEY_FILE --instance-url $INSTANCE_URL $DEFAULT

# Check authentication status
sf org list