#!/bin/bash
GIT_BRANCH_NAME="$1"
GIT_COMMIT_HASH="$2"
DEVHUB_ALIAS="$3"
VERSIONNAME="$4"
VERSIONDESCRIPTION="$5"
#TAGNUMBER="$6"
#TAGGING=$( --tag $TAGNUMBER )

changedPaths=$( git diff-tree --name-only $GIT_BRANCH_NAME $GIT_COMMIT_HASH )
set +e
changedPackages=()
if [ $(echo "$changedPaths" | grep -c '^core_dm$') == 1 ]; then
    changedPackages+=( 'MB-CORE-DM' )
    # Create new package version
    echo "--- Found core_dm path; creating new package version of MB-CORE-DM now ---"
    json=$(sfdx package version create --package MB-CORE-DM --installation-key $INSTALLATIONKEY --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --code-coverage --json)
    echo $json
    status=$(echo $json | jq '.status')
        if [ $status == "0" ]; then
            packageVersionId_core_dm=$(echo $json | jq -r '.result.SubscriberPackageVersionId')
            echo "--- New Package Version Id of MB-CORE-DM package - "$packageVersionId_core_dm
        else
            echo "--- sfdx package version create failed ---"
        fi
fi
# if [ $(echo "$changedPaths" | grep -c '^core_bl$') == 1 ]; then
#    changedPackages+=( 'MB-CORE-BL' )
#    echo "--- Found core_bl path; creating new package version of MB-CORE-BL now ---"
#    json=$(sfdx package version create --package MB-CORE-BL --installation-key $INSTALLATIONKEY --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --code-coverage --json)
#    echo $json
#    status=$(echo $json | jq '.status')
#        if [ $status == "0" ]; then
#            packageVersionId_core_bl=$(echo $json | jq -r '.result.SubscriberPackageVersionId')
#            echo "--- New Package Version Id of MB-CORE-BL package - "$packageVersionId_core_bl
#        else
#            echo "--- sfdx package version create failed ---"
#        fi
#fi
if [ $(echo "$changedPaths" | grep -c '^fs_dm$') == 1 ]; then
    changedPackages+=( 'MB-FS-DM' )
    echo "--- Found fs_dm path; creating new package version of MB-FS-DM now ---"
    json=$(sfdx package version create --package MB-FS-DM --installation-key "$INSTALLATIONKEY" --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --code-coverage --json)
    echo $json
    status=$(echo $json | jq '.status')
        if [ $status == "0" ]; then
            packageVersionId_fs_dm=$(echo $json | jq -r '.result.SubscriberPackageVersionId')
            echo "--- New Package Version Id of MB-FS-DM package - "$packageVersionId_fs_dm
        else
            echo "--- sfdx package version create failed ---"
        fi
fi
if [ $(echo "$changedPaths" | grep -c '^fs_bl$') == 1 ]; then
    changedPackages+=( 'MB-FS-BL' )
    echo "--- Found fs_bl path; creating new package version of MB-FS-BL now ---"
    json=$(sfdx package version create --package MB-FS-BL --installation-key $INSTALLATIONKEY --version-name $VERSIONNAME --wait 60 --target-dev-hub $DEVHUB_ALIAS --definition-file ./config/project-scratch-def.json --version-description $VERSIONDESCRIPTION --code-coverage --json)
    echo $json
    status=$(echo $json | jq '.status')
        if [ $status == "0" ]; then
            packageVersionId_fs_bl=$(echo $json | jq -r '.result.SubscriberPackageVersionId')
            echo "--- New Package Version Id of MB-FS-BL package - "$packageVersionId_fs_bl
        else
            echo "--- sfdx package version create failed ---"
        fi
fi
echo "Changed packages (${#changedPackages[@]}):"
for i in ${changedPackages[@]}; do
    echo "- $i"
done
changedPackagesJson='[]'
if (( ${#changedPackages[@]} > 0 )); then
    changedPackagesJson=$(printf '%s\n' "${changedPackages[@]}" | jq -R . | jq -c -s .)
    echo "$changedPackagesJson"
    else
    echo "no package directory changed, skipping package version creation"
fi
