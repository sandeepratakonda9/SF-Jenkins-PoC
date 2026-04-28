#!/bin/bash
ORG_ALIAS="$1"
set -e
# Verfify sfdx cli installation & version
sf --version

# Set configs
sf config set target-dev-hub=$ORG_ALIAS
sf config list
sf org list