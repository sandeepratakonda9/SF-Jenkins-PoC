#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"
set -e
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./manifest/COM_PicklistFields.xml manifest