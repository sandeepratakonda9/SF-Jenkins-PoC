#!/bin/bash
changedPackagesJson="$1"
TARGET_ORG_ALIAS="$2"
INSTALLATIONKEY="$3"

set -e

echo "--- Changed paths: " $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR') "-> related packages to be installed now ---"

if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_dm') == 1 ]; then
    packageVersionId_core_dm=$(echo $changedPackagesJson | jq -r .packages[0].createdPackageVersionID)
    echo $packageVersionId_core_dm
    echo "--- Starting installation of new package version of MB-CORE-DM with Id '$packageVersionId_core_dm' now ---"
    sfdx package install --package $packageVersionId_core_dm --installation-key $INSTALLATIONKEY --no-prompt --target-org $TARGET_ORG_ALIAS --wait 30
    echo "--- END Package Installation ---"
fi
#if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_bl') == 1 ]; then
#   packageVersionId_core_bl=$(echo $changedPackagesJson | jq -r .packages[1].createdPackageVersionID)
#    echo $packageVersionId_core_bl
#    echo "--- Starting installation of new package version of MB-FS-BL with Id '$packageVersionId_core_bl' now ---"
#    sfdx package install --package $packageVersionId_core_bl --installation-key $INSTALLATIONKEY --no-prompt --target-org $TARGET_ORG_ALIAS --wait 30
#    echo "--- END Package Installation ---"
#fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_dm') == 1 ]; then
    packageVersionId_fs_dm=$(echo $changedPackagesJson | jq -r .packages[2].createdPackageVersionID)
    echo "$packageVersionId_fs_dm"
    echo "--- Starting installation of new package version of MB-FS-BL with Id '"$packageVersionId_fs_dm"' now ---"
    sfdx package install --package "$packageVersionId_fs_dm" --installation-key $INSTALLATIONKEY --no-prompt --target-org $TARGET_ORG_ALIAS --wait 30
    echo "--- END Package Installation ---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_dm') == 1 ]; then
    packageVersionId_fs_bl=$(echo $changedPackagesJson | jq -r .packages[3].createdPackageVersionID)
    echo $packageVersionId_fs_bl
    echo "--- Starting installation of new package version of MB-FS-BL with Id '$packageVersionId_fs_bl' now ---"
    sfdx package install --package $packageVersionId_fs_bl --installation-key $INSTALLATIONKEY --no-prompt --target-org $TARGET_ORG_ALIAS --wait 30
    echo "--- END Package Installation ---"
fi