#!/bin/bash
FROM="$1"
TO="$2"

set -e

# Identify changed paths and create new package versions
changedPaths=$( git diff-tree --name-only $FROM $TO )

changedPackages=()
changedPackagesJson='{"packages": ['
#changedPackagesJson =$(echo $changedPackagesJson | jq)
#echo $changedPackagesJson
if [ $(echo "$changedPaths" | grep -c '^core_dm$') == 1 ]; then
    changedPackages+=( 'MB-CORE-DM' )
    #jq 'changedPackagesJson=[{packageName: "MB-CORE-DM", packageDIR: "core_dm"}]'
    #changedPackagesJson=$(jq -n --arg packageName "MB-CORE-DM" \
              #--arg packageDIR "core_dm" \
              #--arg createdPackageVersionID null \
              #'$ARGS.named')
    changedPackagesJson+='{"packageName": "MB-CORE-DM", "packageDIR": "core_dm"}'
fi
#if [ $(echo "$changedPaths" | grep -c '^core_bl$') == 1 ]; then
#    changedPackages+=( 'MB-CORE-BL' )
#    #jq 'changedPackagesJson=[{packageName: "MB-CORE-BL", packageDIR: "core_bl"}]'
#    #changedPackagesJson=$(jq -n --arg packageName "MB-CORE-BL" \
#              #--arg packageDIR "core_bl" \
#              #--arg createdPackageVersionID null \
#              #'$ARGS.named')
#    changedPackagesJson+='{"packageName": "MB-CORE-BL", "packageDIR": "core_bl", "createdPackageVersionID": ""}'
#fi
if [ $(echo "$changedPaths" | grep -c '^fs_dm$') == 1 ]; then
    if (( ${#changedPackages[@]} > 0 )); then
    changedPackagesJson+=','
    fi
    changedPackages+=( 'MB-FS-DM' )
    #jq 'changedPackagesJson += [{packageName: "MB-FS-DM", packageDIR: "fs_dm"}]'
    #changedPackagesJson=$(jq -n --arg packageName "MB-FS-DM" \
    #          --arg packageDIR "fs_dm" \
    #          --arg createdPackageVersionID null \
    #          '$ARGS.named')
    #changedPackagesJson = $(echo $changedPackagesJson | jq '.packages += [{"packageName": "MB-FS-DM"},{"packageDIR": "fs_dm"}]' )
    #echo $changedPackagesJson
    changedPackagesJson+='{"packageName": "MB-FS-DM", "packageDIR": "fs_dm"}'
fi
if [ $(echo "$changedPaths" | grep -c '^fs_bl$') == 1 ]; then
    if (( ${#changedPackages[@]} > 0 )); then
    changedPackagesJson+=','
    fi
    changedPackages+=( 'MB-FS-BL' )
    #jq 'changedPackagesJson += [{packageName: "MB-FS-BL", packageDIR: "fs_bl"}]'
    #changedPackagesJson+=$(jq -n --arg packageName "MB-FS-BL" \
    #          --arg packageDIR "fs_bl" \
    #          --arg createdPackageVersionID null \
    #          '$ARGS.named')
    changedPackagesJson+='{"packageName": "MB-FS-BL", "packageDIR": "fs_bl"}'
fi
changedPackagesJson+=']}'
#echo "--- changed packages (${#changedPackages[@]}):"
#for i in ${changedPackages[@]}; do
    #echo "- $i"
#done
#changedPackagesJson='[]'
if (( ${#changedPackages[@]} > 0 )); then
    #changedPackagesJson=$(printf '%s\n' "${changedPackages[@]}" | jq -R . | jq -s .)
    echo "${changedPackagesJson}"
else
    echo "--- No package directory changed, process ends  ---"
    exit 1
fi
