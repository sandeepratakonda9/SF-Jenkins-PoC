#!/bin/bash
TARGET_ORG_ALIAS="$1"
DEVHUB_ALIAS="$2"

set +e

# Identify changed paths and create new package versions
changedPaths=$( git diff-tree --name-only ONEOPS-1768-DR1 origin/ONEOPS-1768-DR1 )
changedPackages=()

changedPackagesJson='{ "packages": [ { "packageName": "MB-CORE-DM" }, { "packageName": "MB-CORE-BL" }, { "packageName": "MB-COM-Batch-Control" }, { "packageName": "MB-FS-DM" }, { "packageName": "MB-FS-BL" } ] }'

if [ $(echo "$changedPaths" | grep -c '^core_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[0] += {"packageDIR": "core_dm"}')
    changedPackages+=( 'MB-CORE-DM' )
fi
#if [ $(echo "$changedPaths" | grep -c '^core_bl$') == 1 ]; then
#    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[1] += {"packageDIR": "core_bl"}')
#    changedPackages+=( 'MB-CORE-BL' )
#fi
if [ $(echo "$changedPaths" | grep -c '^com_batch-control$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[2] += {"packageDIR": "com_batch-control"}')
    changedPackages+=( 'MB-FS-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[3] += {"packageDIR": "fs_dm"}')
    changedPackages+=( 'MB-FS-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_bl$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[4] += {"packageDIR": "fs_bl"}')
    changedPackages+=( 'MB-FS-BL' )
fi
if (( ${#changedPackages[@]} > 0 )); then
    echo "--- Changed package directories have been added to JSON ---"
    echo $changedPackagesJson | jq
elif [[ $(echo "$changedPaths" | grep -c '^fs_post') -ge 1 && ${#changedPackages[@]} -eq 0 ]]; then
    echo "--- No package directory changed, but post-directory identified - deployment continues without package creation ---"
    exit 0
else
    echo "--- No relevant directory changed, process ends ---"
    exit 1
fi

################################################################################################################################################################################################################################
#############################################################################################   Packages are IDENTIFIED at this point #############################################################################################
################################################################################################################################################################################################################################


# Before starting process, remove profiles for package creation
rm -r fs_post_access-mgmt/profiles

#echo $changedPackagesJson | jq -c '.packages[]'

#for row in $(echo "$changedPackagesJson" | jq -c '.packages[]'); do
    #packageName=$(echo $row | jq -c '.packageName')
    #echo $packageName
    #packageDIR=$(echo "$row" | jq -c '.packageDIR')
    #echo $packageDIR
    #createdPackageVersionID=$(echo "$row" | jq -c '.createdPackageVersionID')
    #echo $createdPackageVersionID
    #echo "Found changes on: packageName: "$packageName" packageDIR: "$packageDIR" createdPackageVersionID: "$createdPackageVersionID""
    #echo "--- Found $packageDIR path; creating new package version of $packageName now ---"
#done

echo "--- Changed paths: " $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR') "-> the related packages to the identified directories are to be created incrementally now ---"

if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'core_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[0].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(sfdx package version create --package $packageName --installation-key "MBCRM202X" --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json  --json --code-coverage)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[0] += {"createdPackageVersionID": "'$packageVersionId'"}')
    else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi
#if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_bl') == 1 ]; then
#    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[0].packageName')
#    echo "--- Creating new package version of $packageName ---"
#    packageCreationJson=$(sfdx package version create --package $packageName --installation-key "MBCRM202X" --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json  --json --code-coverage)
#    echo "$packageCreationJson" | jq
#    status=$(echo $packageCreationJson | jq '.status')
#    if [ $status == "0" ]; then
#      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
#      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
#      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
#      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[1] += {"createdPackageVersionID": "'$packageVersionId'"}')
#    else
#      echo "--- Package version create of package $packageName failed ---"
#      exit 1
#    fi
#fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'com_batch-control') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[2].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(sfdx package version create --package $packageName --installation-key "MBCRM202X" --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json  --json --code-coverage)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[2] += {"createdPackageVersionID": "'$packageVersionId'"}')
    else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'fs_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[3].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(sfdx package version create --package $packageName --installation-key "MBCRM202X" --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json  --json --code-coverage)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[3] += {"createdPackageVersionID": "'$packageVersionId'"}')
    else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'fs_bl') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[4].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(sfdx package version create --package $packageName --installation-key "MBCRM202X" --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json  --json --code-coverage)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[4] += {"createdPackageVersionID": "'$packageVersionId'"}')
      else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi

# Before continuing the process, restore profiles
git restore fs_post_access-mgmt/profiles

echo "--- JSON file completed - Package version IDs have been added ---"
echo "$changedPackagesJson" | jq 

################################################################################################################################################################################################################################
#############################################################################################   Packages are CREATED at this point #############################################################################################
################################################################################################################################################################################################################################

set -e

echo "--- Created Package version Ids to be INSTALLED now ---"

if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[0].packageName')
    packageVersionId_core_dm=$(echo $changedPackagesJson | jq -r .packages[0].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId_core_dm' now ---"
    sfdx package install --package $packageVersionId_core_dm --installation-key "MBCRM202X" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
#if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_bl') == 1 ]; then
#    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[1].packageName')
#   packageVersionId_core_bl=$(echo $changedPackagesJson | jq -r .packages[1].createdPackageVersionID)
#    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId_core_bl' now ---"
#    sfdx package install --package $packageVersionId_core_bl --installation-key "MBCRM202X" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
#    echo "--- Package Installation of the new version of $packageName completed---"
#fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'com_batch-control') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[2].packageName')
    packageVersionId_fs_dm=$(echo $changedPackagesJson | jq -r .packages[2].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '"$packageVersionId_fs_dm"' now ---"
    sfdx package install --package "$packageVersionId_fs_dm" --installation-key "MBCRM202X" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[3].packageName')
    packageVersionId_fs_dm=$(echo $changedPackagesJson | jq -r .packages[3].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '"$packageVersionId_fs_dm"' now ---"
    sfdx package install --package "$packageVersionId_fs_dm" --installation-key "MBCRM202X" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_bl') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[4].packageName')
    packageVersionId_fs_bl=$(echo $changedPackagesJson | jq -r .packages[4].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId_fs_bl' now ---"
    sfdx package install --package $packageVersionId_fs_bl --installation-key "MBCRM202X" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi

sfdx package installed list --target-org $TARGET_ORG_ALIAS
echo "--- Process completed ---"

################################################################################################################################################################################################################################
############################################################################################   Packages are INSTALLED at this point ############################################################################################
################################################################################################################################################################################################################################


.deployment/scripts/orchastration_mb/post-deployment_core.sh $TARGET_ORG_ALIAS RunLocalTests
.deployment/scripts/orchastration_mb/post-deployment_com.sh $TARGET_ORG_ALIAS RunLocalTests
.deployment/scripts/orchastration_mb/post-deployment_fs.sh $TARGET_ORG_ALIAS RunLocalTests


