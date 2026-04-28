#!/bin/bash
ALIAS="$1"
EXECUTE_ONETIME_CHANGES="$2"
EXECUTE_ONETIME_CHANGES_2="$3"
set -e

#rm -rf fs_dm/main/default/settings/Address.settings-meta.xml #removal due to manual steps to get this deployed
#rm -rf fs_dealerMgmt/customer-package/application/mod2/main/default/applications/Wholesale_App.app-meta.xml
#rm -rf fs_post_org-dependent

chmod +x .deployment/scripts/*.sh && chmod +x .deployment/scripts/orchastration_mb/*.sh && chmod +x .deployment/scripts/scratchOrgs/*.sh && chmod +x .deployment/scripts/orgManagement/*.sh

if [ $EXECUTE_ONETIME_CHANGES == 'TRUE' ]; then
    echo "--- OneHouse onetime changes - included! ---"
    echo "--- Starting Permission Sets assignment ... ---"
    .deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_ohCop/main/default/permissionsets/EU_DigitalLendingAdmin.permissionset-meta.xml
    # Assign relevant User Permission Sets
    sf org assign permset --name VehicleAndAssetLendingPsl EU_DigitalLendingAdmin --target-org $ALIAS
    echo "--- Permission Sets assignment completed! ---"

    echo "--- Starting Deployment of Decision tables and dependencies for OmniStudio components ... ---"
    .deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath "core_dm/main/default/globalValueSets/EU_Market.globalValueSet-meta.xml core_dm/main/default/globalValueSets/EU_LegalEntity.globalValueSet-meta.xml fs_dm/main/default/standardValueSets/CaseType.standardValueSet-meta.xml fs_dm/main/default/objects/Account/fields/FS_KeyAccountManager__c.field-meta.xml core_dm/main/default/objects/Account/fields/EU_BusinessEntityType__c.field-meta.xml core_dm/main/default/objects/Account/fields/EU_LegalEntity__c.field-meta.xml core_dm/main/default/objects/Case/fields/EU_Market__c.field-meta.xml fs_dm/main/default/objects/Account/fields/FS_CorporateCustomer__c.field-meta.xml"
    .deployment/scripts/scratchOrgs/scratchOrgOHPreDeployments.sh $ALIAS
    echo "--- Deployment of Decision tables and dependencies for OmniStudio components completed! ---"

    # remove forceignore entry and deploy dummy named credential
    sed -i '' 's/fs_manual_deployment//g' ".forceignore"
    .deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_manual_deployment/namedCredentials
    .deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_manual_deployment/decisionMatrixDefinition/EU_CreditApproverMatrix.decisionMatrixDefinition-meta.xml
    git restore .forceignore
else
    echo "--- OneHouse onetime changes - ignored! ---"
fi

echo "--- Starting Deployment of Settings ... ---"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_dm/main/default/settings
echo "--- Deployment of Settings completed! ---"

sed -i '' '/<profileSearchLayouts>/,/<\/profileSearchLayouts>/ {
    /<profileSearchLayouts>/,/<\/profileSearchLayouts>/d
    }' "fs_ohCop/main/default/objects/Account/Account.object-meta.xml"

sed -i '' '/<profileSearchLayouts>/,/<\/profileSearchLayouts>/ {
    /<profileSearchLayouts>/,/<\/profileSearchLayouts>/d
    }' "fs_ohCop/main/default/objects/Applicant/Applicant.object-meta.xml"

sed -i '' '/<profileSearchLayouts>/,/<\/profileSearchLayouts>/ {
    /<profileSearchLayouts>/,/<\/profileSearchLayouts>/d
    }' "fs_ohCop/main/default/objects/ApplicationForm/ApplicationForm.object-meta.xml"

sed -i '' '/<profileSearchLayouts>/,/<\/profileSearchLayouts>/ {
    /<profileSearchLayouts>/,/<\/profileSearchLayouts>/d
    }' "fs_ohCop/main/default/objects/PartyProfile/PartyProfile.object-meta.xml"

sed -i '' '/<actionOverrides>/,/<\/actionOverrides>/ {
    /<actionOverrides>/,/<\/actionOverrides>/d
    }' "fs_ohCop/main/default/objects/ApplicationForm/ApplicationForm.object-meta.xml"

sed -i '' '/<actionOverrides>/,/<\/actionOverrides>/ {
    /<actionOverrides>/,/<\/actionOverrides>/d
    }' "fs_ohCop/main/default/objects/DocumentChecklistItem/DocumentChecklistItem.object-meta.xml"

sed -i '' '/<actionOverrides>/,/<\/actionOverrides>/ {
    /<actionOverrides>/,/<\/actionOverrides>/d
    }' "fs_ohCop/main/default/objects/EU_FinancialStatement__c/EU_FinancialStatement__c.object-meta.xml"

sed -i '' '/<actionOverrides>/,/<\/actionOverrides>/ {
    /<actionOverrides>/,/<\/actionOverrides>/d
    }' "fs_ohCop/main/default/objects/InternalOrganizationUnit/InternalOrganizationUnit.object-meta.xml"

sed -i '' '/<actionOverrides>/,/<\/actionOverrides>/ {
    /<actionOverrides>/,/<\/actionOverrides>/d
    }' "fs_ohCop/main/default/applications/EU_MBMContractOrigination.app-meta.xml"

sed -i '' '/<profileActionOverrides>/,/<\/profileActionOverrides>/ {
    /<profileActionOverrides>/,/<\/profileActionOverrides>/d
    }' "fs_ohCop/main/default/applications/EU_MBMContractOrigination.app-meta.xml"

sed -i '' '/<brand>/,/<\/brand>/ {
    /<brand>/,/<\/brand>/d
    }' "fs_ohCop/main/default/applications/EU_MBMContractOrigination.app-meta.xml"

sed -i '' '/<utilityBar>EU_MBM_Contract_Origination_UtilityBar<\/utilityBar>/d' "fs_ohCop/main/default/applications/EU_MBMContractOrigination.app-meta.xml"

echo "--- Starting DEPLOYMENT of data model ---"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun "fs_ohCop/main/default/objects fs_ohCop/main/default/customPermissions fs_ohCop/main/default/externalCredentials fs_ohCop/main/default/globalValueSets fs_ohCop/main/default/groups fs_ohCop/italy/groups fs_ohCop/main/default/queues fs_ohCop/main/default/roles fs_ohCop/main/default/standardValueSets fs_ohCop/main/default/tabs" sourcepath

rm -rf fs_ohCop/main/default/permissionsets/EU_ApexAccess_TranslationService.permissionset-meta.xml
rm -rf fs_ohCop/main/default/permissionsets/EU_VisualForcePageAccess.permissionset-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/sObject_Trigger_Setting.EU_Account.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/sObject_Trigger_Setting.EU_Applicant.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/sObject_Trigger_Setting.EU_ApplicationForm.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/sObject_Trigger_Setting.EU_ContentVersion.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/sObject_Trigger_Setting.EU_PartyProfile.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_AccountUpdatePartyProfile.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_AccountUpdatePartyProfileOnInsert.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_AccountUpdatePartyProfileOnUpdate.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantCreateChangeLogOnInsert.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantCreatePartyProfileOnInsert.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantCreateUpdateChangeLogUpdate.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantPopulateIdentifierOnInsert.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantPopulateIdentifierOnUpdate.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantUpdatePartyProfileOnUpdate.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantValidateTINOnInsert.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicantValidateTINOnUpdate.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicationFormCreateAccountContact.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicationFormDocumentArchive.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicationFormInitiateC3Callout.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_ApplicationFormUpdatePPAccCon.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_CreateDCIsAfterApplicantInsert.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_CreateDCIsOnApplicationStageChange.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_PartyProfileUpdateRelatedAccount.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_PreventInvalidDCIFileTypeUpload.md-meta.xml
rm -rf fs_ohCop/main/default/customMetadata/Trigger_Action.EU_UpdateDCIStatusOnContentVersionInsert.md-meta.xml

.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun "fs_dm/main/default/objects/Account/fields fs_ohCop/main/default/objects fs_ohCop/main/default/customMetadata fs_ohCop/main/default/customPermissions fs_ohCop/main/default/externalCredentials fs_ohCop/main/default/globalValueSets fs_ohCop/main/default/groups fs_ohCop/italy/groups fs_ohCop/main/default/queues fs_ohCop/main/default/roles fs_ohCop/main/default/standardValueSets fs_ohCop/main/default/tabs" sourcepath

.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun "fs_ohCop/main/default/applications/EU_MBMContractOrigination.app-meta.xml fs_ohCop/main/default/flexipages/MBM_Contract_Origination_UtilityBar.flexipage-meta.xml fs_ohCop/main/default/staticresources" sourcepath

.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun "fs_bl/main/default/permissionsets/FS_VehicleandAssetLendingUser.permissionset-meta.xml fs_ohCop/main/default/permissionsets fs_ohCop/main/default/permissionsetgroups/EU_PERSONA_MBFS_Devops_Manager.permissionsetgroup-meta.xml" sourcepath      

if [ $EXECUTE_ONETIME_CHANGES_2 == 'TRUE' ]; then
    echo "--- OneHouse onetime changes - included! ---"
    sf org assign permset --name EU_PERSONA_MBFS_Devops_Manager --target-org $ALIAS
else
    echo "--- OneHouse onetime changes - ignored! ---"
fi

echo "--- Starting DEPLOYMENT of case assignment rules ---"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun "fs_post_config/assignmentRules/Case.assignmentRules-meta.xml" sourcepath
echo "--- Starting DEPLOYMENT of sharing model ---"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun "fs_ohCop/main/default/sharingRules fs_post_access-mgmt/sharingRules" sourcepath

git restore fs_ohCop/main/default/objects
git restore fs_ohCop/main/default/applications/EU_MBMContractOrigination.app-meta.xml
git restore fs_ohCop/main/default/permissionsets
git restore fs_ohCop/main/default/customMetadata
#git restore fs_dm/main/default/settings/Address.settings-meta.xml
echo "--- DEPLOYMENT of pre-steps COMPLETED --- please continue with REGULAR SCRIPT NOW ..."