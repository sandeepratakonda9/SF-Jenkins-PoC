#!/bin/bash
ALIAS="$1"
INSTALLATIONKEY="$2"

set -e
# Get latest package versions
latestVersionCOREDM=$(sfdx package version list -p MB-CORE-DM -o CreatedDate --concise | tail -1 | awk '{print $3}')
#latestVersionCOREBL=$(sfdx package version list -p MB-CORE-BL -o CreatedDate --concise | tail -1 | awk '{print $3}')
latestVersionCOMBATCH=$(sfdx package version list -p MB-COM-Batch-Control -o CreatedDate --concise | tail -1 | awk '{print $3}')
latestVersionFSDM=$(sfdx package version list -p MB-FS-DM -o CreatedDate --concise | tail -1 | awk '{print $3}')
latestVersionFSBL=$(sfdx package version list -p MB-FS-BL -o CreatedDate --concise | tail -1 | awk '{print $3}')

# Install the packages in target org
echo "--- Starting Package installation ... ---"
.deployment/scripts/packageInstall.sh $ALIAS $latestVersionCOREDM $INSTALLATIONKEY
#.deployment/scripts/packageInstall.sh $ALIAS $latestVersionCOREBL $INSTALLATIONKEY
.deployment/scripts/packageInstall.sh $ALIAS $latestVersionCOMBATCH $INSTALLATIONKEY
.deployment/scripts/packageInstall.sh $ALIAS $latestVersionFSDM $INSTALLATIONKEY
.deployment/scripts/packageInstall.sh $ALIAS $latestVersionFSBL $INSTALLATIONKEY
sfdx package installed list
echo "--- All packages installed ! ---"