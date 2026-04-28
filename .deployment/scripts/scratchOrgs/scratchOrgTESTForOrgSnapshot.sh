#!/bin/bash
ALIAS="$1"
DEVHUB="$2"
set -e

echo "--- Starting Scratch org creation ... ---"
sf org create scratch --definition-file config/project-scratch-def-full.json --alias $ALIAS --target-dev-hub $DEVHUB --duration-days 1 --wait 30 --set-default --no-track-source
echo "--- Scratch org creation completed! ---"

echo "--- Starting Scratch org setup ... ---"
.deployment/scripts/scratchOrgs/scratchOrgSetup.sh $ALIAS plain
echo "--- Scratch org setup completed! ---"

echo "--- Starting Scratch org metadata prep ... ---"
.deployment/scripts/orchastration_mb/pre-undeployableMetadata_scratchOrgs.sh SO_SUPPORTS_OMNI
echo "--- Scratch org metadata prep completed! ---"

echo "--- Starting Scratch org deployments ... ---"
.deployment/scripts/orchastration_mb/deploy-dir-structure.sh $ALIAS NoTestRun FALSE SCRATCHORGPLAIN TRUE
echo "--- Scratch org deployments completed! ---"

echo "------ Restoring irrelevant & undeployable metadata ... ------"
git restore ./