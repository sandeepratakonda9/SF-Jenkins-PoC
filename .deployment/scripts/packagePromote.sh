#!/bin/bash
ALIAS="$1"
PACKAGEVERSIONID="$2"

set -e
# Promote the package version
sf package version promote --package $PACKAGEVERSIONID --target-dev-hub $ALIAS --no-prompt