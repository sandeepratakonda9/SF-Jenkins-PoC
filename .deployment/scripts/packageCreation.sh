#!/bin/bash
PACKAGENAME="$1"
DEVHUB_ALIAS="$2"
INSTALLATIONKEY="$3"
CODECOVERAGE="$4"
JSONOUTPUT="$5"
VERSIONNAME="$6"
VERSIONDESCRIPTION="$7"

set -e

if [ ! -z $CODECOVERAGE ] && [ $CODECOVERAGE == 'calculateCodeCoverage' ]; then
CODECOVERAGE="--code-coverage"
else
CODECOVERAGE="--skip-validation"
fi

if [ ! -z $JSONOUTPUT ] && [ $JSONOUTPUT == 'formatOutputAsJSON' ]; then
JSONOUTPUT="--json"
else
JSONOUTPUT=""
fi

if [ ! -z $VERSIONNAME ] && [ ! -z $VERSIONDESCRIPTION ]; then
VERSION_NAME="--version-name $VERSIONNAME"
VERSION_DESCRIPTION="--version-description $VERSIONDESCRIPTION"
else
VERSION_NAME=""
VERSION_DESCRIPTION=""
fi

# Create new package versions
sf package version create --package $PACKAGENAME --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --wait 60 --installation-key "$INSTALLATIONKEY" $CODECOVERAGE $JSONOUTPUT $VERSION_NAME $VERSION_DESCRIPTION 
sleep 1m