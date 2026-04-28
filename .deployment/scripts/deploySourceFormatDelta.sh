#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"
FROM="$3"
TO="$4"
CHECKONLY="$5"

if [ $CHECKONLY == 'CheckOnly' ] && [ ! -z $CHECKONLY ]; then
CHECKONLY="--dry-run"
else
CHECKONLY=""
fi

set -e

# Genereate folder and identify delta 
mkdir ./temp-delta-deployment
sf sgd source delta --from ${FROM%$'\n'} --to $TO --output-dir ./temp-delta-deployment --generate-delta
ls -R -l ./temp-delta-deployment

# Deploy delta metadata
if [ $FORMAT == 'sourcepath' ] && [ -z $TESTLEVEL ]; then
sf project deploy start --source-dir ./temp-delta-deployment --target-org $ALIAS --wait 120 --verbose --ignore-conflicts $CHECKONLY
elif [ $FORMAT == 'sourcepath' ] && [ ! -z $TESTLEVEL ]; then
sf project deploy start --source-dir ./temp-delta-deployment --test-level $TESTLEVEL --target-org $ALIAS --verbose --wait 120 --ignore-conflicts $CHECKONLY
else
echo "Invalid source deployment command"
fi