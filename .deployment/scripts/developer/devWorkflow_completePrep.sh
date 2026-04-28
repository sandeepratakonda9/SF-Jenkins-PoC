#!/bin/bash
MBMTEAM="$1"
TICKETNUMBER="$2"
DEVHUB_ALIAS="$3"
DEFAULT="$3"
PUSH="$4"
DATALOAD="$5"

set -e

# Do some git magic to create a new branch from develop and check it out
git switch develop
git pull
git checkout -b $MBMTEAM/$TICKETNUMBER
git push --set-upstream origin $MBMTEAM/$TICKETNUMBER

# Start Scratch Org creation, package installation and metadata push + data load
.deployment/scripts/scratchOrgCreateFull.sh MBM_SO_$TICKETNUMBER $DEVHUB_ALIAS true true true