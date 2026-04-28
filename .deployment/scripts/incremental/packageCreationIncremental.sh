#!/bin/bash
changedPackagesJson="$1"
DEVHUB_ALIAS="$2"
VERSIONNAME="$3"
VERSIONDESCRIPTION="$4"
INSTALLATIONKEY="$5"
#echo $changedPackageJSON
set -e

# Before starting process, remove profiles for package creation
#rm -r fs_post_access-mgmt/profiles

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

#echo "--- Changed paths: " $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR') "-> related packages to be created now ---"

if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_dm') == 1 ]; then
    #echo "Creating new package version of MB-CORE-DM now"
    sfdx package version create --package MB-CORE-DM --installation-key MBCRM202X --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --skip-validation --json #--code-coverage #$TAGGING
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'core_bl') == 1 ]; then
    #echo "Creating new package version of MB-CORE-BL now"
    sfdx package version create --package MB-CORE-BL --installation-key MBCRM202X --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --skip-validation --json #--code-coverage #$TAGGING
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_dm') == 1 ]; then
    #echo "Creating new package version of MB-FS-DM now"
    packageCreationJson=$(sfdx package version create --package MB-FS-DM --installation-key MBCRM202X --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --skip-validation --json) #--code-coverage #$TAGGING
    #echo $packageCreationJson
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      #echo "--- New Package Version Id of MB-FS-DM package - "$packageVersionId
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[2] += {"createdPackageVersionID": "'$packageVersionId'"}')
    #else
      #echo "--- sfdx package version create failed ---"
    fi
fi
if [ $(echo "$changedPackagesJson" | jq -c '.packages[]' | jq -c '.packageDIR' | grep -c 'fs_dm') == 1 ]; then
    #echo "Creating new package version of MB-FS-BL now"
    packageCreationJson=$(sfdx package version create --package MB-FS-BL --installation-key MBCRM202X --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --skip-validation --json) #--code-coverage #$TAGGING
    #echo $packageCreationJson
    status=$(echo $packageCreationJson | jq '.status')
    if [ $status == "0" ]; then
      packageVersionId=$(echo $packageCreationJson | jq -r '.result.SubscriberPackageVersionId')
      #echo "--- New Package Version Id of MB-FS-DM package - "$packageVersionId
      changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[3] += {"createdPackageVersionID": "'$packageVersionId'"}')
      #else
      #echo "--- sfdx package version create failed ---"
    fi
fi

echo "$changedPackagesJson"

