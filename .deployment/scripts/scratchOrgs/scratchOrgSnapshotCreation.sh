#!/bin/bash
ALIAS="$1"
DEVHUB="$2"
SO_SNAPSHOT_SCOPE="$3"
set -e

if [ $SO_SNAPSHOT_SCOPE == "plain" ]; then
    echo "--- Recreating plain Scratch Org Snapshot with just only managed packages installed! ---"
    sf org delete snapshot --snapshot MBMorgsnapPLAIN --target-dev-hub $DEVHUB --no-prompt

    sf org create snapshot --name MBMorgsnapPLAIN --source-org $ALIAS --target-dev-hub $DEVHUB --description "Includes current features, settings & packages"

    sleep 20m

    sf org get snapshot --snapshot MBMorgsnapPLAIN --target-dev-hub $DEVHUB

    sf org list snapshot --target-dev-hub $DEVHUB

elif [ $SO_SNAPSHOT_SCOPE == "testing" ]; then
    echo "--- Recreating Testing Scratch Org Snapshot"
    sf org delete snapshot --snapshot MBMorgsnapOMNI --target-dev-hub $DEVHUB --no-prompt

    sf org create snapshot --name MBMorgsnapOMNI --source-org $ALIAS --target-dev-hub $DEVHUB --description "Includes current features, settings & new stuff for testing"

    sleep 20m

    sf org get snapshot --snapshot MBMorgsnapOMNI --target-dev-hub $DEVHUB

    sf org list snapshot --target-dev-hub $DEVHUB
else
    echo "--- Recreating Scratch Org Snapshot which contains common as well as rarely changing folders (core_dm, common_frameworks, fs_dm, fs_ivr, fs_bl, fs_clientServices)"
    sf org delete snapshot --snapshot MBMorgsnapFULL --target-dev-hub $DEVHUB --no-prompt

    sf org create snapshot --name MBMorgsnapFULL --source-org $ALIAS --target-dev-hub $DEVHUB --description "Includes current features, settings, packages as well as common & rarely changing dirs"

    sleep 20m

    sf org get snapshot --snapshot MBMorgsnapFULL --target-dev-hub $DEVHUB

    sf org list snapshot --target-dev-hub $DEVHUB
fi


# https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_org_commands_unified.htm#cli_reference_org_create_snapshot_unified 