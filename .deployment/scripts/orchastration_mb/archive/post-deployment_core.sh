#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"

set -e
chmod +x .deployment/scripts/*.sh

.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./core_dm/main/default/standardValueSets sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./manifest/CORE_PicklistFields.xml manifest