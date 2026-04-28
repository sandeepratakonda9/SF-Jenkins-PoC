#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Default to the root directory if no directory is provided
directory="${1:-./}"

# Verify that the provided path is a directory
if [ ! -d "$directory" ]; then
    echo "Error: '$directory' is not a valid directory."
    exit 1
fi

# Variable to track if duplicates were found
duplicates_found=false

# Function to find duplicates and store them in an array
find_duplicates() {
    fd --type f --exclude .git --exclude fs_post_org-dependent --exclude '*.field-meta.xml' --exclude '*.listView-meta.xml' --exclude '*.validationRule-meta.xml' --exclude '*.fieldTranslation-meta.xml' --exclude '*.json' --exclude fs_ohCop/main/default/profiles/Admin.profile-meta.xml --exclude fs_post_access-mgmt/objects/Asset/Asset.object-meta.xml --exclude '*CustomLabels.labels-meta.xml' --exclude '*EU_Master.recordType-meta.xml' --exclude '*Layout.layout-meta.xml' --exclude README.md --exclude '*Setting' --exclude '*Statement' --exclude 'fs_post_config/queues/*.queue-meta.xml' --base-directory "$directory" | \
    xargs -n1 basename | \
    sort | \
    uniq -d
}

# Use mapfile if available, otherwise fall back to a while loop to read the duplicates into an array
if command -v mapfile > /dev/null; then
    mapfile -t duplicate_files < <(find_duplicates)
else
    # Fallback: read the output into an array manually
    duplicate_files=()
    while IFS= read -r file; do
        duplicate_files+=("$file")
    done < <(find_duplicates)
fi

# Check if any duplicates were found
if [ ${#duplicate_files[@]} -gt 0 ]; then
    duplicates_found=true
    echo "Duplicate file names found:"
    
    # Loop over the duplicate file names and print their locations
    for filename in "${duplicate_files[@]}"; do
        echo "Duplicate file name: $filename"
        fd --type f --exclude .git --exclude fs_post_org-dependent --exclude '*.field-meta.xml' --exclude '*.listView-meta.xml' --exclude '*.validationRule-meta.xml' --exclude '*.fieldTranslation-meta.xml' --exclude '*.json' --exclude fs_ohCop/main/default/profiles/Admin.profile-meta.xml --exclude fs_post_access-mgmt/objects/Asset/Asset.object-meta.xml --exclude '*CustomLabels.labels-meta.xml' --exclude '*EU_Master.recordType-meta.xml' --exclude '*Layout.layout-meta.xml' --exclude README.md --exclude '*Setting' --exclude '*Statement' --exclude 'fs_post_config/queues/*.queue-meta.xml' --base-directory "$directory" -g "$filename"
        echo
    done
fi

# If duplicates were found, exit with a non-zero status to fail the GitHub Actions workflow
if [ "$duplicates_found" = true ]; then
    echo "Error: Duplicate files found."
    exit 1
else
    echo "No duplicate files found."
fi
