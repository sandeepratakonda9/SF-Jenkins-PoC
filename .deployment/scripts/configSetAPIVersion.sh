#!/bin/bash
API_VERSION="$1"
set -e
# Verfify sfdx cli installation & version
sf --version

# Set configs
sf config set org-api-version=$API_VERSION
sf config list