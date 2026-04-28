#!/bin/bash
ALIAS="$1"
PACKAGEVERSIONID="$2"
INSTALLATIONKEY="$3"
if [ ! -z $INSTALLATIONKEY ]; then
USEINSTALLATIONKEY="--installation-key $INSTALLATIONKEY"
else
USEINSTALLATIONKEY=""
fi

set -e
# Install the package in target org
sf package install --package $PACKAGEVERSIONID --target-org $ALIAS --wait 60 --no-prompt $USEINSTALLATIONKEY
sf package installed list --target-org $ALIAS