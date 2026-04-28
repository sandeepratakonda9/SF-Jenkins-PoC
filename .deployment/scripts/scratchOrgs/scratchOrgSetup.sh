#!/bin/bash
ALIAS="$1"
SO_SNAPSHOT_SCOPE="$2"
set -e

echo "--- Pre-Deployment of needed metadata ... ---"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath "fs_ohCop/main/default/permissionsets/EU_DigitalLendingAdmin.permissionset-meta.xml core_dm/main/default/objects/Case/fields/AT_Category__c.field-meta.xml core_dm/main/default/standardValueSets/CaseReason.standardValueSet-meta.xml"
echo "--- Starting Permission Sets assignment ... ---"
# Assign relevant User Permission Sets
sf org assign permset --name AutomotiveFoundationUserPsl BillingCollectionsAndRecoverySpecialist IndustriesServiceExcellence OmniStudioAdmin VehicleAndAssetFinanceFndtnPsl VehicleAndAssetLendingPsl EU_DigitalLendingAdmin --target-org $ALIAS
echo "--- Permission Sets assignment completed! ---"

echo "--- Starting Deployment of Settings ... ---"
.deployment/scripts/deploySourceFormat.sh $ALIAS NoTestRun sourcepath fs_dm/main/default/settings
echo "--- Deployment of Settings completed! ---"

echo "--- Starting OmniStudio Metadata API activation ... ---"
.deployment/scripts/orgManagement/orgManager.sh $ALIAS enableOmniSudioSettings
echo "--- OmniStudio Metadata API activation completed! ---"
echo "--- Starting Package installation ... ---"
# Marketing Cloud package - 256.0.0.2
.deployment/scripts/packageInstall.sh $ALIAS 04t6S000001ACTCQA4
# Nebula Logger package - 4.9.10.1
.deployment/scripts/packageInstall.sh $ALIAS 04t5Y0000015mv8QAA
# Trigger Actions Framework package - 0.2.0.0
.deployment/scripts/packageInstall.sh $ALIAS 04t3h000004VaLmAAK
# OmniStudio package - 258.7.0.1
.deployment/scripts/packageInstall.sh $ALIAS 04tKb000000tAvfIAE
# Genesys cloud package - 4.17.0.1
.deployment/scripts/packageInstall.sh $ALIAS 04t3a000000LdmyAAC
# Dealer Management DEP Package@5.322
.deployment/scripts/packageInstall.sh $ALIAS 04tN1000005kzyTIAQ
# Dealer Management DEP Package - Mod2 - 5.145.0.1
.deployment/scripts/packageInstall.sh $ALIAS 04tN1000004z56vIAA
# Cloud Compliance Package - 3.11.1
.deployment/scripts/packageInstall.sh $ALIAS 04tKg000000D3J5 U2alY89nR1zRgW7
# Enhanced Files List/Winter 21 - 1.5.0
.deployment/scripts/packageInstall.sh $ALIAS 04t5w000005b2U4AAI

# Packages on PROD but not on Scratch orgs since no dependencies to them:
# - MarketingCloudConnect - 1.5.0.3 - 04t61000000gWo1AAE 
# - Trail Tracker - 3.12.0.1 - 04t1Q000000s4kQQAQ 
# - Salesforce Adoption Dashboards - 1.0.0.1 - 04tam000000VeKXAA0
# - Salesforce.com CRM Dashboards - 1.0.0.1 - 04t50000000EcdrAAC 

echo "--- All packages installed ! ---"
if [ $SO_SNAPSHOT_SCOPE == "plain" ]; then
    echo "Scratch org creation completed! No further directories deployed. Org only has packages installed!"
else
    # Deploy directories that are quite static
    .deployment/scripts/scratchOrgs/scratchOrgDeployStaticDirStructure.sh $ALIAS
fi