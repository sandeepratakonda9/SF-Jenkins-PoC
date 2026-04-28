#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"

set -e
chmod +x .deployment/scripts/*.sh

# Deployments of unpackaged metadata
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath ./fs_post_org-dependent/PROD