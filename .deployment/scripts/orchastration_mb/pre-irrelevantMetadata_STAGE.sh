#!/bin/bash
POSTORG_Validation="$1"

set -e

# Temp remove folders that should not be considered during delta nor full deployment against STAGE
rm -r fs_manual_deployment
rm -r fs_post_org-dependent/PROD
rm -r fs_post_org-dependent/SIT
rm -r fs_post_org-dependent/OHqa

# Temp remove of files that should not be considered during delta nor full deployment/Validation against SIT
rm -rf fs_athlon/main/default/reportTypes
rm -rf fs_post_config/reportTypes/FS_FinancialAgreements.reportType-meta.xml
rm -rf fs_post_config/reportTypes/FS_IndividualEmailResultswwoCI.reportType-meta.xml
rm -rf fs_post_ui/reports/FS_RetentionTemplates/FS_CustomerIntentStatusUndecided.report-meta.xml
rm -rf fs_post_ui/reports/FS_RetentionTemplates/FS_IntentStatusWithSourceAndEmailName.report-meta.xml
rm -rf fs_post_ui/dashboards/FS_CustomerIntentDashboards/FS_CustomerIntentDashboard.dashboard-meta.xml

# remove Service Channels due to validation error "Field Integrity: This channel uses the status-based capacity model. Select a value for Capacity Model" - which is not possible to be set https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_servicechannel.htm 
rm -rf fs_post_config/serviceChannels

if [ "$POSTORG_Validation" = 'validation' ]; then
    echo "------ Validation Mode: Skipping undeployable metadata to avoid duplicate file errors ------"
    # Temp remove folders that should not be considered during delta nor full validation against STAGE
    rm -r fs_post_org-dependent/STAGE/labels
    rm -r fs_dm/main/default/objects/FS_CreditSummary__c/FS_CreditSummary__c.object-meta.xml
fi