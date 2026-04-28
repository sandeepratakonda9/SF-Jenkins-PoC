#!/bin/bash
echo "------ SCAN CODE: Skipping metadata from ScanCode to avoid Failures ------"

# List of directories to remove
dirs_to_remove=(
    "./temp-delta-deployment/fs_ohCop/main/default/lwc/eUNewApplicationMultiLanguage"
    # Add more directories below as needed
)

# Loop through the list and remove if exists
for dir in "${dirs_to_remove[@]}"; do
    if [ -d "$dir" ]; then
        rm -r "$dir"
        echo "Removed $dir"
    else
        echo "Directory $dir does not exist, skipping removal."
    fi
done