#!/bin/bash
FROM="$1"
TO="$2"
DEVHUB_ALIAS="$3"
TARGET_ORG_ALIAS="$4"
INSTALLATIONKEY="$5"
VERSIONNAME="$6"
VERSIONDESCRIPTION="$7"


set +e

################################################################################################################################################################################################################################
#################################################################################################   Packages get IDENTIFIED  ###################################################################################################
################################################################################################################################################################################################################################

changedPaths=$( git diff-tree --name-only origin/$FROM origin/$TO )
changedPackages=()

changedPackagesJson='{ "packages": [ { "packageName": "MB-CORE-DM" }, { "packageName": "MB-COM-Batch-Control" }, { "packageName": "MB-FS-DM" }, { "packageName": "MB-FS-IVR" }, { "packageName": "MB-FS-BL" }, { "packageName": "MB-FS-Credit-DM" }, { "packageName": "MB-FS-Credit-BL" }, { "packageName": "MB-FS-ClientServices-DM" }, { "packageName": "MB-FS-ClientServices-BL" } ] }'

if [ $(echo "$changedPaths" | grep -c '^core_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[0] += {"packageDIR": "core_dm"}')
    changedPackages+=( 'MB-CORE-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^com_batch-control$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[1] += {"packageDIR": "com_batch-control"}')
    changedPackages+=( 'MB-FS-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[2] += {"packageDIR": "fs_dm"}')
    changedPackages+=( 'MB-FS-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_ivr$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[3] += {"packageDIR": "fs_ivr"}')
    changedPackages+=( 'MB-FS-IVR' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_bl$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[4] += {"packageDIR": "fs_bl"}')
    changedPackages+=( 'MB-FS-BL' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_credit_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[5] += {"packageDIR": "fs_credit_dm"}')
    changedPackages+=( 'MB-FS-Credit-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_credit_bl$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[6] += {"packageDIR": "fs_credit_bl"}')
    changedPackages+=( 'MB-FS-Credit-BL' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_clientServices_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[7] += {"packageDIR": "fs_clientServices_dm"}')
    changedPackages+=( 'MB-FS-ClientServices-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_clientServices_bl$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[8] += {"packageDIR": "fs_clientServices_bl"}')
    changedPackages+=( 'MB-FS-ClientServices-BL' )
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
###################################################################################################   Packages get CREATED   ###################################################################################################
################################################################################################################################################################################################################################


# Before starting process, remove profiles for package creation
rm -r fs_post_access-mgmt/profiles
rm -r fs_post_omni/flexipages

echo "--- Changed paths: " $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR') "-> the related packages to the identified directories are to be created incrementally now ---"

if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'core_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[0].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
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
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'com_batch-control') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[1].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[1] += {"createdPackageVersionID": "'$packageVersionId'"}')
    else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'fs_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[2].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
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
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_ivr') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[3].packageName')
    echo "--- Creating new package version of $packageName ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
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
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
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
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'fs_credit_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[5].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[5] += {"createdPackageVersionID": "'$packageVersionId'"}')
      else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'fs_credit_bl') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[6].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[6] += {"createdPackageVersionID": "'$packageVersionId'"}')
      else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'fs_clientServices_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[7].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[7] += {"createdPackageVersionID": "'$packageVersionId'"}')
      else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[].packageDIR' | grep -c 'fs_clientServices_bl') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[8].packageName')
    echo "--- Creating new package version of $packageName now ---"
    packageCreationJson=$(.deployment/scripts/packageCreation.sh $packageName $DEVHUB_ALIAS $INSTALLATIONKEY calculateCodeCoverage formatOutputAsJSON $VERSIONNAME $VERSIONDESCRIPTION)
    echo "$packageCreationJson" | jq
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      packageVersionNumber=$(sfdx package version list -p $packageName -o CreatedDate --concise | tail -1 | awk '{print $2}')
      echo "--- New Package Version Id of $packageName package - $packageVersionId - $packageVersionNumber ---"
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[8] += {"createdPackageVersionID": "'$packageVersionId'"}')
      else
      echo "--- Package version create of package $packageName failed ---"
      exit 1
    fi
fi

# Before continuing the process, restore profiles
git restore .

echo "--- JSON file completed - Package version IDs have been added ---"
echo "$changedPackagesJson" | jq 

################################################################################################################################################################################################################################
#################################################################################################   Packages get INSTALLED   ###################################################################################################
################################################################################################################################################################################################################################

set -e

echo "--- Created Package version Ids to be INSTALLED now ---"

if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[0].packageName')
    packageVersionId=$(echo $changedPackagesJson | jq -r .packages[0].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId' now ---"
    sfdx package install --package $packageVersionId --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'com_batch-control') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[1].packageName')
    packageVersionId=$(echo $changedPackagesJson | jq -r .packages[1].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '"$packageVersionId"' now ---"
    sfdx package install --package "$packageVersionId" --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[2].packageName')
    packageVersionId=$(echo $changedPackagesJson | jq -r .packages[2].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '"$packageVersionId"' now ---"
    sfdx package install --package "$packageVersionId" --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_ivr') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[3].packageName')
   packageVersionId=$(echo $changedPackagesJson | jq -r .packages[3].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId' now ---"
    sfdx package install --package $packageVersionId --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_bl') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[4].packageName')
    packageVersionId=$(echo $changedPackagesJson | jq -r .packages[4].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId' now ---"
    sfdx package install --package $packageVersionId --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_credit_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[5].packageName')
    packageVersionId=$(echo $changedPackagesJson | jq -r .packages[5].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId' now ---"
    sfdx package install --package $packageVersionId --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_credit_bl') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[6].packageName')
    packageVersionId=$(echo $changedPackagesJson | jq -r .packages[6].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId' now ---"
    sfdx package install --package $packageVersionId --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_clientServices_dm') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[7].packageName')
    packageVersionId_fs_clientServices_dm=$(echo $changedPackagesJson | jq -r .packages[7].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId_fs_clientServices_dm' now ---"
    sfdx package install --package $packageVersionId_fs_clientServices_dm --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_clientServices_bl') == 1 ]; then
    packageName=$(echo "$changedPackagesJson" | jq -r '.packages[8].packageName')
    packageVersionId_fs_clientServices_bl=$(echo $changedPackagesJson | jq -r .packages[8].createdPackageVersionID)
    echo "--- Starting installation of new package version of $packageName with Id '$packageVersionId_fs_clientServices_bl' now ---"
    sfdx package install --package $packageVersionId_fs_clientServices_bl --installation-key "$INSTALLATIONKEY" --no-prompt --target-org $TARGET_ORG_ALIAS --wait 60
    echo "--- Package Installation of the new version of $packageName completed---"
fi

sfdx package installed list --target-org $TARGET_ORG_ALIAS
echo "--- Process completed ---"

################################################################################################################################################################################################################################
####################################################################################################   Process completed #######################################################################################################
################################################################################################################################################################################################################################