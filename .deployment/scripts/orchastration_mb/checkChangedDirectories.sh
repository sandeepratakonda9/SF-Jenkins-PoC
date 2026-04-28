#!/bin/bash
set -e
# List of required directories
relevant_dirs=( "common_frameworks" "core_dm" "fs_dm" "fs_bl" "fs_retention" "fs_clientServices" "fs_credit" "fs_industryCloud" "fs_ivr" "fs_post_access-mgmt" "fs_post_config" "fs_post_ui" "fs_dealerMgmt" "fs_ohCop" "fs_ohCmp" "fs_athlon")

# Check if "temp" directory exists
if [ -d "./temp-delta-deployment" ]; then
    # Check if at least one of the required directories exists inside "temp"
    found=false
    for dir in "${relevant_dirs[@]}"; do
        if [ -d "./temp-delta-deployment/$dir" ]; then
            found=true
            break
        fi
    done

    if $found; then
        echo "TRUE"
    else
        echo "FALSE"
    fi
else
    echo "FALSE"
fi
