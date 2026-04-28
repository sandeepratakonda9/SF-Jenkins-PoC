#!/bin/bash
ALIAS="$1"
DEVHUB="$2"
set -e

echo "not for use as script during CI/CD"
exit 1

sf org create snapshot --name ONEOPS_ORGSNAP1 --source-org $ALIAS --target-dev-hub $DEVHUB --description "Includes features, settings & packages"

sf org get snapshot --snapshot ONEOPS_ORGSNAP1 --target-dev-hub $DEVHUB

sf org list snapshot --target-dev-hub $DEVHUB

sf org delete snapshot --snapshot BaseSnapshot --target-dev-hub $DEVHUB

# https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_org_commands_unified.htm#cli_reference_org_create_snapshot_unified 