#!/bin/bash
ALIAS="$1"

set -e

# deploy global value sets first 
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_credit/main/default/globalValueSets

# temp remove obsolete files in this step
rm -r fs_credit/main/default/objects/FS_Application__c/listViews
rm -r fs_credit/main/default/objects/FS_Application__c/validationRules
rm -r fs_credit/main/default/objects/FS_ApplicationParty__c/validationRules
rm -r fs_credit/main/default/objects/FS_ApplicationParty__c/fields/FS_FraudControl__c.field-meta.xml
rm -r fs_credit/main/default/objects/FS_Application__c/fields/FS_ReviewedApplicationEvaluation__c.field-meta.xml

# deploy required objects
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath "fs_credit/main/default/objects/FS_Application__c fs_credit/main/default/objects/FS_ApplicationParty__c fs_credit/main/default/objects/FS_Term__c"

# restore files
git restore fs_credit/main/default/objects/FS_Application__c/listViews
git restore fs_credit/main/default/objects/FS_Application__c/validationRules
git restore fs_credit/main/default/objects/FS_ApplicationParty__c/validationRules
git restore fs_credit/main/default/objects/FS_ApplicationParty__c/fields/FS_FraudControl__c.field-meta.xml
git restore fs_credit/main/default/objects/FS_Application__c/fields/FS_ReviewedApplicationEvaluation__c.field-meta.xml

# remove forceignore entry and deploy decision matrices
sed -i 's/fs_manual_deployment//g' ".forceignore"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_manual_deployment/decisionMatrixDefinition

# restore entry
git restore .forceignore