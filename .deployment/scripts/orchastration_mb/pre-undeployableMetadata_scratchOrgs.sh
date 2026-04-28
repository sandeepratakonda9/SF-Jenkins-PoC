#!/bin/bash
OMNISTUDIO_SUPPORT="$1"
SO_OH_VALIDATION="$2"

set -e

if [ $OMNISTUDIO_SUPPORT == 'SO_SUPPORTS_OMNI' ]; then
echo "--- Scratch Org supports OmniStudio components - included! ---"
else
echo "--- Scratch Org does not support OmniStudio components - removed! ---"
# Temp remove due to missing deployability against Scratch Orgs as long as OmniStudio Metadata API cannot be enabled
    rm -r fs_industryCloud/clientServices/omniDataTransforms
    rm -r fs_industryCloud/clientServices/omniIntegrationProcedures
    rm -r fs_industryCloud/clientServices/omniScripts
    rm -r fs_industryCloud/clientServices/omniUiCard
    rm -r fs_industryCloud/credit
    rm -r fs_industryCloud/retention
    rm -r fs_industryCloud/ohCop
fi

# Temp remove metadata of due to not resolvable dependencies or deployment issues to scratch orgs (e.g. missing users)
## Client Services
rm -r fs_post_ui/reports/FS_CS_ClientServicesAgentReports
rm -r fs_post_ui/reports/FS_CS_ClientServicesManagerReports
rm -r fs_post_ui/dashboards/FS_CS_ClientServicesAgentDashboards
rm -r fs_post_ui/dashboards/FS_CS_ClientServicesManagerDashboards
rm -r fs_post_ui/dashboards/FS_EmailMarketingDashboards
rm -r fs_post_ui/dashboards/FS_CustomerIntentDashboards/FS_CustomerIntentDashboard.dashboard-meta.xml
rm -r fs_post_ui/flexipages/FS_CS_HomePageDefault.flexipage-meta.xml
rm -r fs_post_config/reportTypes/FS_ServiceCatalogRequests.reportType-meta.xml
rm -r fs_post_ui/reports/FS_CS_AdminReports/FS_CS_No_of_Other_Documents_Requested.report-meta.xml
rm -r fs_clientServices/main/default/flexipages/FS_CS_FinancialAgreement.flexipage-meta.xml
sed -i '/<networkMemberGroups>/,/<\/networkMemberGroups>/d' "fs_clientServices/us/networks/Secure Message Center.network-meta.xml"

## Credit
rm -r fs_credit/main/default/flows/FS_CreditReport_AT_RecordAlertCreation.flow-meta.xml
rm -r fs_credit/main/default/flows/FS_CreditReport_AT_CreateFraudRecordAlert.flow-meta.xml
rm -r fs_credit/main/default/flows/FS_RecordAlert_AT_Enrichment.flow-meta.xml
rm -r fs_credit/main/default/classes/FS_CreditReportFlow_TEST.cls
rm -r fs_credit/main/default/classes/FS_CreditReportFlow_TEST.cls-meta.xml
rm -r fs_post_ui/dashboards/FS_ServiceOmniChannelDashboards.dashboardFolder-meta.xml
rm -r fs_post_ui/dashboards/FS_ServiceOmniChannelDashboards/FS_OmniChannelPerformance.dashboard-meta.xml
rm -r fs_post_ui/dashboards/FS_CaseControllingDashboards/FS_ManagerHomepage.dashboard-meta.xml
rm -r fs_post_ui/dashboards/FS_CaseOperationalDashboards/FS_AgentHomepage.dashboard-meta.xml
rm -r fs_bl/main/default/permissionsets/FS_Application_ViewAll.permissionset-meta.xml
rm -r fs_bl/main/default/permissionsetgroups/FS_Global_CRMA_Access.permissionsetgroup-meta.xml
rm -r fs_post_access-mgmt/permissionsetgroups/FS_OneHouseOwnDataBackup.permissionsetgroup-meta.xml
rm -r fs_ivr/main/default/connectedApps/FS_Genesys_Cloud_Connector_New_Instance_glbloauth.ecaGlblOauth-meta.xml
# --- Remove all Connected Apps for Scratch Org deployment ---
find . -type d -name "connectedApps" -exec rm -rf {} +
find . -type f -name "*.connectedApp-meta.xml" -delete
find . -type f -name "*.ecaGlblOauth-meta.xml" -delete

## Dealer Management
rm -r fs_dealerMgmt/mod1-excludedFromPackage/main/default/approvalProcesses
rm -r fs_dealerMgmt/mod1-excludedFromPackage/main/default/connectedApps
rm -r fs_dealerMgmt/mod2-excludedFromPackage/main/default/connectedApps
rm -r fs_dealerMgmt/integrations-package/main/default/permissionsetgroups/FS_SFP_DMITSystemAdmin.permissionsetgroup-meta.xml
rm -r fs_dealerMgmt/integrations-package/main/default/permissionsetgroups/FS_SFP_DMBusinessSystemAdmin.permissionsetgroup-meta.xml
rm -r fs_dealerMgmt/mod1-excludedFromPackage/main/default/permissionsets/DEP_Package__Delete_Records.permissionset-meta.xml

## OneHouse COP
rm -r fs_dm/main/default/settings/Address.settings-meta.xml #removal always due to manual steps to get this deployed
rm -r fs_post_access-mgmt/profiles/EU_MBFS_Standard.profile-meta.xml #Removal because of application dependency 
if [ $SO_OH_VALIDATION == 'TRUE' ]; then
    echo "--- OneHouse components - handled! ---"
    # remove not working components of OH
    rm -r fs_ohCop/main/default/experiences/COPUI1/routes/enablementProgramDetail.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/routes/enablementProgramLesson.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/routes/enablementProgramLink.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/routes/enablementProgramList.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/routes/enablementProgramMilestone.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/routes/enablementProgramRelatedList.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/routes/enablementProgramVideo.json

    rm -r fs_ohCop/main/default/experiences/COPUI1/views/enablementLessonExercise.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/views/enablementLinkExercise.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/views/enablementMilestoneDetail.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/views/enablementProgramDetail.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/views/enablementProgramList.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/views/enablementProgramRelatedList.json
    rm -r fs_ohCop/main/default/experiences/COPUI1/views/enablementVideoExercise.json

    rm -rf fs_ohCop/main/default/reportTypes
    rm -rf fs_ohCop/main/default/reports
    rm -rf fs_ohCop/main/default/dashboards


    rm -rf fs_ohCop/main/default/uiFormatSpecificationSets
    rm -rf fs_ohCop/main/default/translations/pt_PT.translation-meta.xml
    rm -rf fs_ohCop/main/default/standardValueSetTranslations/AddressCountryCode-pt_PT.standardValueSetTranslation-meta.xml
    rm -rf fs_ohCop/main/default/standardValueSetTranslations/AddressStateCode-pt_PT.standardValueSetTranslation-meta.xml
else
    echo "--- OneHouse components - ignored! ---"
    rm -r fs_ohCop/main/default/objects/Account/Account.object-meta.xml # dependency to profile which is also not deployed then
    rm -r fs_post_config/assignmentRules/Case.assignmentRules-meta.xml # dependency to groups which are not deployed
fi

#athlon
rm -r fs_athlon/main/default/dashboards/AthlonStandardGlobalCustomerService/vGhBFeanLTPpbsmRxFazoPszSYMRSw1.dashboard-meta.xml

# Search and replace deleted metadata to resolve dependency issues
## General 
if [ $OMNISTUDIO_SUPPORT == 'SO_SUPPORTS_OMNI' ]; then
    echo "--- Scratch Org supports OmniStudio components - included! ---"
else
echo "--- Scratch Org does not support OmniStudio components - replaced! ---"
    # Temp remove due to missing deployability against Scratch Orgs as long as OmniStudio Metadata API cannot be enabled
    sed -i 's/FS_ServiceExcellenceGenericAlertCard/ServiceExcellenceGenericAlertCard/g' "fs_post_ui/flexipages/FS_FinancialAgreement.flexipage-meta.xml"
    ## Credit
    ### OmniStudio dependencies
    #### FS_Application.flexipage
    sed -i 's/FS_Credit_ActiveRecordAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_Application.flexipage-meta.xml"
    sed -i 's/FS_Credit_DismissRecordAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_Application.flexipage-meta.xml"
    sed -i 's/FS_Credit_SystemErrorsAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_Application.flexipage-meta.xml"
    sed -i 's/FS_Credit_ApplicationPartyInfo/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_Application.flexipage-meta.xml"
    sed -i 's/FS_Credit_ApplicationVehicleInfo/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_Application.flexipage-meta.xml"
    sed -i 's/FS_Credit_DealStructureInfo/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_Application.flexipage-meta.xml"

    #### FS_ApplicationParty.flexipage
    sed -i 's/FS_Credit_SystemErrorsAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_ApplicationParty.flexipage-meta.xml"
    sed -i 's/FS_Credit_ActiveRecordAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_ApplicationParty.flexipage-meta.xml"
    sed -i 's/FS_Credit_DismissRecordAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_ApplicationParty.flexipage-meta.xml"

    #### FS_CreditReport.flexipage
    sed -i 's/FS_Credit_ActiveRecordAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_CreditReport.flexipage-meta.xml"
    sed -i 's/FS_Credit_DismissRecordAlerts/ServiceExcellenceGenericAlertCard/g' "fs_credit/main/default/flexipages/FS_CreditReport.flexipage-meta.xml"
fi

## Client Services
sed -i 's/FS_CS_HomePageDefault/FS_HomePage/g' "fs_post_access-mgmt/applications/FS_MBMClientServices.app-meta.xml"
sed -i 's/FS_AgentHomepage/FS_CS_US_SecureMessageCenterAgentInsights/g' "fs_post_ui/flexipages/FS_HomePage.flexipage-meta.xml"
sed -i 's/FS_ManagerHomepage/FS_CS_US_SecureMessageCenterManagerInsights/g' "fs_post_ui/flexipages/FS_HomePage.flexipage-meta.xml"
sed -i 's/FS_CS_FinancialAgreement/FS_FinancialAgreement/g' "fs_post_access-mgmt/applications/FS_MBMClientServices.app-meta.xml"
sed -i 's/RoleAndSubordinates/Role/g' "fs_post_ui/dashboards/FS_CaseOperationalDashboards.dashboardFolder-meta.xml"
sed -i 's/RoleAndSubordinates/Role/g' "fs_post_ui/dashboards/FS_CustomerIntentDashboards.dashboardFolder-meta.xml"


## OH-COP
if [ $SO_OH_VALIDATION == 'TRUE' ]; then
    echo "--- OneHouse components - handled! ---"

    sed -i 's/EU_MuleContractAPIEndpoint/IBAN_Validator/g' "fs_ohCop/main/default/externalServiceRegistrations/EUPurchaseInvoiceExternalService.externalServiceRegistration-meta.xml" 

    sed -i '/<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/ {
    /<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/d
    }' "fs_ohCop/main/default/flexipages/EU_InternalReview.flexipage-meta.xml"

    sed -i '/<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/ {
    /<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/d
    }' "fs_ohCop/main/default/flexipages/EU_Corporate.flexipage-meta.xml"

    sed -i '/<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/ {
    /<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/d
    }' "fs_ohCop/main/default/flexipages/EU_IntegrationProviderExecutionRecordPage.flexipage-meta.xml"

    sed -i '/<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/ {
    /<fieldInstanceProperties>/,/<\/fieldInstanceProperties>/d
    }' "fs_post_ui/flexipages/FS_FinancialAgreement.flexipage-meta.xml"

    sed -i '/<itemInstances>/ {N;N;N;N;N;N;N;N;N;N;N;N;N;/<itemInstances>\n[[:space:]]*<componentInstance>\n[[:space:]]*<componentInstanceProperties>\n[[:space:]]*<name>dashboardName<\/name>\n[[:space:]]*<value>XxLHpELHkdZklRTSomFRBwjXDiZVRU<\/value>\n[[:space:]]*<\/componentInstanceProperties>\n[[:space:]]*<componentInstanceProperties>\n[[:space:]]*<name>hideOnError<\/name>\n[[:space:]]*<value>true<\/value>\n[[:space:]]*<\/componentInstanceProperties>\n[[:space:]]*<componentName>desktopDashboards:embeddedDashboard<\/componentName>\n[[:space:]]*<identifier>desktopDashboards_embeddedDashboard<\/identifier>\n[[:space:]]*<\/componentInstance>\n[[:space:]]*<\/itemInstances>/d}' fs_ohCop/main/default/flexipages/EU_MBMContractOriginationHomePage.flexipage-meta.xml

else
    echo "--- OneHouse components - ignored! ---"

    sed -i '/<applicationVisibilities>/,/<\/applicationVisibilities>/ {
    /<application>EU_MBMContractOrigination<\/application>/,/<\/applicationVisibilities>/d
    }' "fs_post_access-mgmt/profiles/FS_Admin.profile-meta.xml"
fi


### OmniStudio dependencies
if [ $OMNISTUDIO_SUPPORT == 'SO_SUPPORTS_OMNI' ]; then
    echo "--- Scratch Org supports OmniStudio components - included! ---"
else
    echo "--- Scratch Org does not support OmniStudio components - replaced! ---"
    # Temp remove due to missing deployability against Scratch Orgs as long as OmniStudio Metadata API cannot be enabled
    sed -i 's/EUApplicantRecordDetailCard/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_Applicant.flexipage-meta.xml"

    sed -i 's/EUApplicantRelatedList/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUDriverRelatedList/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUApplicantOverviewList/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUApplicantSelectorCard/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUApplicantDetailButtonsCard/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUApplicantViewCard/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EU_ApplicationFormAndInvoiceCompareDatatable/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EU_ShowDealerPayoutMessage/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUDisplayResponseOnActivationRequest/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUKYCRelatedList/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EUApplicantPCDRelatedList/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"
    sed -i 's/EU_ApplicationActionItemRelatedList/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_ApplicationFormRecordPage.flexipage-meta.xml"

    sed -i 's/EU_ApplicationActionItemRelatedList/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_InternalReview.flexipage-meta.xml"

    sed -i 's/EU_ConfidentialCard/ServiceExcellenceGenericAlertCard/g' "fs_ohCop/main/default/flexipages/EU_MBMContractOriginationHomePage.flexipage-meta.xml"
fi

# Search and replace references to undeployed metadata (like named principals) to resolve dependency issues
sed '/<externalCredentialPrincipalAccesses>/,/<\/externalCredentialPrincipalAccesses>/d' "fs_bl/main/default/permissionsets/FS_KongOauthNamedPrincipalAccess.permissionset-meta.xml" > temp_file.xml && mv temp_file.xml "fs_bl/main/default/permissionsets/FS_KongOauthNamedPrincipalAccess.permissionset-meta.xml"
sed '/<tabVisibilities>/,/<\/tabVisibilities>/d' "fs_post_access-mgmt/profiles/Admin.profile-meta.xml" > temp_file.xml && mv temp_file.xml "fs_post_access-mgmt/profiles/Admin.profile-meta.xml"
sed '/<layoutAssignments>/,/<\/layoutAssignments>/d' "fs_post_access-mgmt/profiles/Admin.profile-meta.xml" > temp_file.xml && mv temp_file.xml "fs_post_access-mgmt/profiles/Admin.profile-meta.xml"
sed -i 's/standard__OnlineSales/standard__Marketing/g' "fs_post_access-mgmt/profiles/AT_AthlonService.profile-meta.xml"
sed -i 's/standard__OnlineSales/standard__Marketing/g' "fs_post_access-mgmt/profiles/FS_Admin.profile-meta.xml"
sed -i 's/standard__OnlineSales/standard__Marketing/g' "fs_post_access-mgmt/profiles/FS_Agent.profile-meta.xml"
sed -i 's/standard__OnlineSales/standard__Marketing/g' "fs_post_access-mgmt/profiles/FS_API_User.profile-meta.xml"
sed -i 's/standard__OnlineSales/standard__Marketing/g' "fs_post_access-mgmt/profiles/FS_Business.profile-meta.xml"
sed -i 's/standard-OnlineSalesHome/standard-Opportunity/g' "fs_post_access-mgmt/profiles/FS_Admin.profile-meta.xml"
sed -i 's/standard-OnlineSalesHome/standard-Opportunity/g' "fs_post_access-mgmt/profiles/FS_Agent.profile-meta.xml"
sed -i 's/standard-OnlineSalesHome/standard-Opportunity/g' "fs_post_access-mgmt/profiles/FS_API_User.profile-meta.xml"
sed -i 's/standard-OnlineSalesHome/standard-Opportunity/g' "fs_post_access-mgmt/profiles/FS_Business.profile-meta.xml"

#FS_Admin profile issue fix
sed -i '/<objectPermissions>/,/<\/objectPermissions>/d' "fs_post_access-mgmt/profiles/FS_Admin.profile-meta.xml"
sed -i '/<permissionSets>FS_CO_CollectionPlan_Generic_R<\/permissionSets>/d' "fs_ohCop/main/default/permissionsetgroups/EU_PERSONA_MBFS_Credit_Underwriter.permissionsetgroup-meta.xml"
