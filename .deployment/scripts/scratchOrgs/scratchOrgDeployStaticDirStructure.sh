#!/bin/bash
ALIAS="$1"

set -e

# Core dir
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath core_dm

# Common dirs
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath common_frameworks

sleep 1m

# FS dirs
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_dm
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_ivr
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_bl
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_industryCloud/retention
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_retention
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_industryCloud/clientServices
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_clientServices
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_dealerMgmt
