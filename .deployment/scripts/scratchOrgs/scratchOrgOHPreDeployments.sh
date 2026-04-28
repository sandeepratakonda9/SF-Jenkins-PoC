#!/bin/bash
ALIAS="$1"

set -e

# deploy global value sets & custom permissions first + CMP collections groups for dependencies in sharing rules
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath "fs_ohCop/main/default/globalValueSets fs_ohCop/main/default/customPermissions fs_ohCmp/fs_collections/main/default/groups"

# deploy required objects + tabs + permission sets
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath "fs_ohCop/main/default/objects/EU_BusinessRulesDocumentUpload__c fs_ohCop/main/default/objects/EU_HandoverActivationsAutomationRules__c fs_ohCop/main/default/objects/EU_IntegrationControllerForMarkets__c fs_ohCop/main/default/objects/EU_LockingControllerForFeatures__c fs_dm/main/default/objects/EU_IntegrationEndpoint__mdt fs_ohCop/main/default/objects/EU_MarketConfiguration__mdt fs_ohCop/main/default/objects/EU_HTTPCalloutConfiguration__mdt fs_ohCop/main/default/objects/EU_IndustryDetails__c fs_ohCop/main/default/tabs/EU_BusinessRulesDocumentUpload__c.tab-meta.xml fs_ohCop/main/default/tabs/EU_HandoverActivationsAutomationRules__c.tab-meta.xml fs_ohCop/main/default/permissionsets/EU_DocumentUploadBusinessRule_Administrator.permissionset-meta.xml fs_ohCop/main/default/permissionsets/EU_Business_Rules_Document_Upload_Administrator.permissionset-meta.xml fs_ohCop/main/default/permissionsets/EU_Handover_Activations_Automation_Rules_Administrator.permissionset-meta.xml fs_ohCop/main/default/permissionsets/EU_IntegrationControllerForMarkets_Generic_Administrator.permissionset-meta.xml fs_ohCop/main/default/permissionsets/EU_LockingControllerForFeatures_Generic_Administrator.permissionset-meta.xml fs_ohCop/main/default/objects/ApplicationFormProduct fs_ohCop/main/default/objects/ApplicationFormProductProposal fs_ohCop/main/default/objects/ApplicationForm/fields/EU_RetentionDate__c.field-meta.xml fs_ohCop/main/default/objects/ApplicationFormSellerItem fs_ohCop/main/default/objects/AssessmentQuestion fs_ohCop/italy/AssessmentQuestions fs_ohCop/italy/AssessmentQuestionSets fs_ohCop/main/default/objects/EU_LocalizationMapping__c fs_ohCop/main/default/objects/EU_Invoice__c fs_ohCop/main/default/objects/EU_LegalEntity__mdt fs_ohCop/main/default/objects/EU_InvoiceLineItem__c fs_ohCop/main/default/objects/EU_VATCodeMappings__mdt fs_dm/main/default/objects/DocumentChecklistItem/fields/EU_DocumentVisibility__c.field-meta.xml fs_ohCop/main/default/objects/EU_OmniStudioComponentsVisibilityRules__c fs_ohCop/main/default/objects/Product2/fields/EU_Source__c.field-meta.xml"

# assign permission sets
sf org assign permset --name EU_Business_Rules_Document_Upload_Administrator EU_DocumentUploadBusinessRule_Administrator EU_Handover_Activations_Automation_Rules_Administrator EU_IntegrationControllerForMarkets_Generic_Administrator EU_LockingControllerForFeatures_Generic_Administrator --target-org $ALIAS

# import data to decision tables
# https://help.salesforce.com/s/articleView?id=001117447&type=1 && https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference_data_commands_unified.htm#cli_reference_data_import_bulk_unified 
sf data import bulk --file ".deployment/files/ohCop/post-deployment/MBM_OH_DecisionTables_EU_BusinessRulesDocumentUpload__c.csv" --sobject EU_BusinessRulesDocumentUpload__c --wait 10 --target-org $ALIAS --line-ending CRLF --column-delimiter COMMA
sf data import bulk --file ".deployment/files/ohCop/post-deployment/MBM_OH_DecisionTables_EU_HandoverActivationsAutomationRules__c.csv" --sobject EU_HandoverActivationsAutomationRules__c --wait 10 --target-org $ALIAS --line-ending LF --column-delimiter COMMA
sf data import bulk --file ".deployment/files/ohCop/post-deployment/MBM_OH_DecisionTables_EU_IntegrationControllerForMarkets__c.csv" --sobject EU_IntegrationControllerForMarkets__c --wait 10 --target-org $ALIAS --line-ending CRLF --column-delimiter COMMA
sf data import bulk --file ".deployment/files/ohCop/post-deployment/MBM_OH_DecisionTables_EU_LockingControllerForFeatures__c.csv" --sobject EU_LockingControllerForFeatures__c --wait 10 --target-org $ALIAS --line-ending CRLF --column-delimiter COMMA

# remove forceignore entry and deploy decision tables & named creds w/o certs
sed -i 's/fs_manual_deployment//g' ".forceignore"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath "fs_manual_deployment/decisionTables fs_manual_deployment/namedCredentials/IBAN_Validator.namedCredential-meta.xml fs_ohCop/main/default/externalCredentials/IBAN_Validator.externalCredential-meta.xml"
git restore .forceignore