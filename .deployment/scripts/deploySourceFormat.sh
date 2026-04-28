#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"
FORMAT="$3"
DIRTODEPLOY="$4"
DESTRUCTIVE="$5"

if [ ! -z $DESTRUCTIVE ] && [ $DESTRUCTIVE == 'TRUE' ]; then
DESTRUCTIVE="--post-destructive-changes ./temp-delta-deployment/destructiveChanges/destructiveChanges.xml"
else
DESTRUCTIVE=""
fi

echo -e "──────────────────────────────────────────────────────────────────────────\n\nStarting deployment of $DIRTODEPLOY folder ...\n\n──────────────────────────────────────────────────────────────────────────"

set -e
if [ $FORMAT == 'sourcepath' ] && [ $TESTLEVEL == 'RUNDEFAULT' ]; then
sf project deploy start --source-dir $DIRTODEPLOY --target-org $ALIAS --wait 120 --verbose --ignore-conflicts $DESTRUCTIVE
elif [ $FORMAT == 'sourcepath' ] && [ $TESTLEVEL != 'RUNDEFAULT' ]; then
sf project deploy start --source-dir $DIRTODEPLOY --test-level $TESTLEVEL --target-org $ALIAS --verbose --wait 120 --ignore-conflicts $DESTRUCTIVE
elif [ $FORMAT == 'manifest' ] && [ $TESTLEVEL != 'RUNDEFAULT' ]; then
sf project deploy start --manifest $DIRTODEPLOY --test-level $TESTLEVEL --target-org $ALIAS --verbose --wait 120 --ignore-conflicts $DESTRUCTIVE
else
echo "Invalid source deployment command"
fi