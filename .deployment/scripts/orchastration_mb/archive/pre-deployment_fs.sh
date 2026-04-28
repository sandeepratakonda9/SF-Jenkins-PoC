#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"

set -e
chmod +x .deployment/scripts/*.sh

# Pre-Deployments due to CLI Issues or failing package upgrades
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/standardValueSets sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./manifest/FS_PicklistFields.xml manifest
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/groups sourcepath