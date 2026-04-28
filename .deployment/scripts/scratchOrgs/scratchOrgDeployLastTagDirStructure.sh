#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"
SLEEPING="$3"
DEPLOYDEALERMGMT="$4"

set -e

# Fetch all tags and branches
git fetch --all --tags

# Get the latest tag matching the pattern SIT-OH-COP_*
latest_tag=$(git tag -l "SIT-OH-COP_*" --sort=-v:refname | head -n 1)

if [ -z "$latest_tag" ]; then
  echo "No tags found matching the pattern SIT-OH-COP_*"
  exit 1
fi

echo "Latest tag found: $latest_tag"

# Checkout the state of the repository at the latest tag
git checkout "$latest_tag"

echo "--- Starting Scratch org deployment ... ---"
.deployment/scripts/orchastration_mb/pre-undeployableMetadata_scratchOrgs.sh SO_SUPPORTS_OMNI
.deployment/scripts/orchastration_mb/deploy-dir-structure.sh $ALIAS NoTestRun FALSE SCRATCHORGPLAIN TRUE
