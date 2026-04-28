#!/bin/bash
ALIAS="$1"
PACKAGENAME="$2"
INSTALLATIONKEY="$3"
if [ ! -z $INSTALLATIONKEY ]; then
USEINSTALLATIONKEY="--installation-key $INSTALLATIONKEY"
else
USEINSTALLATIONKEY=""
fi

set -e

PACKAGEVERSIONID=$(sf package installed list --target-org $ALIAS --json | jq -r --arg name "$PACKAGENAME" '.result[] | select(.SubscriberPackageName == $name) | .SubscriberPackageVersionId') 
echo "--- Installed package version of $PACKAGENAME identified and to be installed: $PACKAGEVERSIONID ---"

# Install the package in target org
sf package install --package $PACKAGEVERSIONID --target-org $ALIAS --wait 60 --no-prompt $USEINSTALLATIONKEY
sf package installed list --target-org $ALIAS
