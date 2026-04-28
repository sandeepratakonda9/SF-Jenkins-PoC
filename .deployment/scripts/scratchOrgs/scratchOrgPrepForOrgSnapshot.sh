#!/bin/bash
ALIAS="$1"
DEVHUB="$2"
SO_SNAPSHOT_SCOPE="$3"
set -e

echo "--- Starting Scratch org creation ... ---"
sf org create scratch --definition-file config/project-scratch-def-full.json --alias $ALIAS --target-dev-hub $DEVHUB --duration-days 1 --wait 30 --set-default --no-track-source
echo "--- Scratch org creation completed! ---"

echo "--- Starting Scratch org setup ... ---"
.deployment/scripts/scratchOrgs/scratchOrgSetup.sh $ALIAS $SO_SNAPSHOT_SCOPE
echo "--- Scratch org setup completed! ---"