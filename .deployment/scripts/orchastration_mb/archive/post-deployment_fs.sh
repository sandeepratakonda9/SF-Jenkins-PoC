#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"

set -e
chmod +x .deployment/scripts/*.sh

# Deployments of unpackaged metadata
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_post_config sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_post_omni sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_post_ui sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_post_access-mgmt sourcepath

# Re-Deployments due to CLI Issues or failing package upgrades
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/standardValueSets sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./manifest/FS_PicklistFields.xml manifest
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/groups sourcepath

# ListViews - update this list using 'find . -path '*/listViews' -type d'
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/objects/FS_AlertCodeSetting__mdt/listViews sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/objects/FS_FlowRoleQueueSetting__mdt/listViews sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/objects/Case/listViews sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/objects/FS_FinancialAgreement__c/listViews sourcepath
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL ./fs_dm/main/default/objects/Account/listViews sourcepath