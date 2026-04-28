#!/bin/bash
RELEASE_VERSION="$1"
TARGET_ORG="$2"
TARGET_BRANCH="$3"

# Load JSON data from sfdx request
json=$(sf package installed list --target-org $TARGET_ORG --json)

# Extract package versions for "MB" packages
MBPackages=$(echo $json | jq -r '.result[] | select(.SubscriberPackageName | startswith("MB")) | { SubscriberPackageName, SubscriberPackageVersionId, SubscriberPackageVersionNumber }')


TAG_NAME="$RELEASE_VERSION"
TAG_MESSAGE="Version $RELEASE_VERSION with Package Version Ids: $MBPackages"

git tag -a "$TAG_NAME" -m "$TAG_MESSAGE"
git push origin "$TAG_NAME"
