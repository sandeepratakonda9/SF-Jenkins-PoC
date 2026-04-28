#!/bin/bash
TARGET_ORG_ALIAS="$1"
set -e

echo "--- Starting Package installations & deployments ... ---"

# CORE-DM package
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000000kvbgAAA "MBCRM202X"
# Post-Deployment CORE
.deployment/scripts/orchastration_mb/post-deployment_core.sh $TARGET_ORG_ALIAS RunLocalTests

# COM-Batch-Control package
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000000kvblAAA "MBCRM202X"
# Post-Deployment COM
.deployment/scripts/orchastration_mb/post-deployment_com.sh $TARGET_ORG_ALIAS RunLocalTests


# FS-DM package
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000001W4baAAC "MBCRM202X"
# FS-IVR package
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000001W4bpAAC "MBCRM202X"

# FS-BL package
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000001W4buAAC "MBCRM202X"

# Credit
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000000kvc5AAA "MBCRM202X"
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000000kvcAAAQ "MBCRM202X"

# Pre-Deployment FS
.deployment/scripts/orchastration_mb/pre-deployment_fs.sh $TARGET_ORG_ALIAS RunLocalTests

# Client Services
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000000kvcFAAQ "MBCRM202X"
.deployment/scripts/packageInstall.sh $TARGET_ORG_ALIAS 04t8a000000kvcZAAQ "MBCRM202X"

# Post-Deployment FS
.deployment/scripts/orchastration_mb/post-deployment_fs.sh $TARGET_ORG_ALIAS RunLocalTests

echo "--- Process completed ---"



