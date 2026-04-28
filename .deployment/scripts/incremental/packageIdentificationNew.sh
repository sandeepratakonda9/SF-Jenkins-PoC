#!/bin/bash
FROM="$1"
TO="$2"

set -e

# Identify changed paths and create new package versions
changedPaths=$( git diff-tree --name-only origin/$FROM origin/$TO )
changedPackages=()

changedPackagesJson='{ "packages": [ { "packageName": "MB-CORE-DM" }, { "packageName": "MB-CORE-BL" }, { "packageName": "MB-FS-DM" }, { "packageName": "MB-FS-BL" } ] }'

if [ $(echo "$changedPaths" | grep -c '^core_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[0] += {"packageDIR": "core_dm"}')
    changedPackages+=( 'MB-CORE-DM' )
fi
#if [ $(echo "$changedPaths" | grep -c '^core_bl$') == 1 ]; then
#    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[1] += {"packageDIR": "core_bl"}')
#    changedPackages+=( 'MB-CORE-BL' )
#fi
if [ $(echo "$changedPaths" | grep -c '^fs_dm$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[2] += {"packageDIR": "fs_dm"}')
    changedPackages+=( 'MB-FS-DM' )
fi
if [ $(echo "$changedPaths" | grep -c '^fs_bl$') == 1 ]; then
    changedPackagesJson=$(echo "$changedPackagesJson" | jq '.packages[3] += {"packageDIR": "fs_bl"}')
    changedPackages+=( 'MB-FS-BL' )
fi
if (( ${#changedPackages[@]} > 0 )); then
    echo "--- Changed package directories have been added to JSON ---"
    echo $changedPackagesJson | jq
elif [[ $(echo "$changedPaths" | grep -c '^fs_post') -ge 1 && ${#changedPackages[@]} -eq 0 ]]; then
    echo "--- No package directory changed, but post-directory identified - deployment continues without package creation ---"
else
    echo "--- No relevant directory changed, process ends ---"
fi
