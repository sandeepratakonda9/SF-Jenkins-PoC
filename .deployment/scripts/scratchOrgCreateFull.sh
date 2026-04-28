#!/bin/bash
ALIAS="$1"
DEVHUB_ALIAS="$2"
DEFAULT="$3"
PUSH="$4"
DATALOAD="$5"
if [ $DEFAULT == 'true' ]; then
SETDEFAULTUSER="--set-default"
else
SETDEFAULTUSER=""
fi
set -e

# Temp remove omniStudio components due to missing deployability against Scratch Orgs as long as OmniStudio Metadata API cannot be enabled
rm -r fs_industryCloud/clientServices/omniDataTransforms
rm -r fs_industryCloud/clientServices/omniIntegrationProcedures
rm -r fs_industryCloud/clientServices/omniScripts
rm -r fs_industryCloud/retention/omniUiCard

echo "--- Starting Scratch Org creation ... ---"
sf org create scratch --definition-file config/project-scratch-def.json --alias $ALIAS --target-dev-hub $DEVHUB_ALIAS --duration-days 14 --wait 30 $SETDEFAULTUSER
sf org list
echo "--- Scratch Org creation completed ! ---"

echo "--- Starting Permission Sets assignment ... ---"
# Assign relevant User Permission Sets
sf org assign permset --name AutomotiveFoundationUserPsl IndustriesServiceExcellence OmniStudioAdmin --target-org $ALIAS
echo "--- Permission Sets assignment completed! ---"

echo "--- Starting Package installation ... ---"
# Marketing Cloud package
.deployment/scripts/packageInstall.sh $ALIAS 04t6S000001UjutQAC
# Nebula Logger package
.deployment/scripts/packageInstall.sh $ALIAS 04t5Y0000015mv8QAA
# Trigger Actions Framework package
.deployment/scripts/packageInstall.sh $ALIAS 04t3h000004VaLmAAK
# TrailTracker
.deployment/scripts/packageInstall.sh $ALIAS 04t1Q000000s4kQQAQ
# OmniStudio package
.deployment/scripts/packageInstall.sh $ALIAS 04t4W0000038bRqQAI
# Genesys cloud package
.deployment/scripts/packageInstall.sh $ALIAS 04t3a000000LdmyAAC

echo "--- All packages installed ! ---"

# Start metadata push
if [ $PUSH == 'true' ]; then
echo "--- Starting metadata push ... ---"
sfdx force:source:push -u $ALIAS
    if [ $DATALOAD == 'true' ]; then
    # Start data load
    echo "--- Starting data load ... ---"
    chmod +x .data-source/*.sh
    .data-source/loadSampleData.sh $ALIAS
    else
    echo "--- Data load completed ! ---"
    fi
else
echo "--- Push skipped - Data load won't be executed as well - a blank Scratch Org is ready now ! ---"
fi

# Restore all repo changes
git restore .