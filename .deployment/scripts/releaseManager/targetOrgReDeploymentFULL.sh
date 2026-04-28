#!/bin/bash
TARGET_ORG_ALIAS="$1"
set -e

echo "--- Starting Package installation ... ---"

.deployment/scripts/orchastration_mb/pre-deployment_fs.sh $TARGET_ORG_ALIAS RunLocalTests

.deployment/scripts/packageReInstallCurrent.sh $TARGET_ORG_ALIAS "MB-CORE-DM" "MBCRM202X"
.deployment/scripts/orchastration_mb/post-deployment_core.sh $TARGET_ORG_ALIAS RunLocalTests


# COM-Batch-Control package
.deployment/scripts/packageReInstallCurrent.sh $TARGET_ORG_ALIAS "MB-COM-Batch-Control" "MBCRM202X"
.deployment/scripts/orchastration_mb/post-deployment_com.sh $TARGET_ORG_ALIAS RunLocalTests   

# FS-DM package
.deployment/scripts/packageReInstallCurrent.sh $TARGET_ORG_ALIAS "MB-FS-DM" "MBCRM202X"
.deployment/scripts/packageReInstallCurrent.sh $TARGET_ORG_ALIAS "MB-FS-BL" "MBCRM202X"
.deployment/scripts/packageReInstallCurrent.sh $TARGET_ORG_ALIAS "MB-FS-Credit-DM" "MBCRM202X"
.deployment/scripts/packageReInstallCurrent.sh $TARGET_ORG_ALIAS "MB-FS-Credit-BL" "MBCRM202X"
.deployment/scripts/orchastration_mb/post-deployment_fs.sh $TARGET_ORG_ALIAS RunLocalTests
.deployment/scripts/orchastration_mb/post-deployment_STAGE.sh $TARGET_ORG_ALIAS RunLocalTests  

echo "--- Process completed ---"
