#!/bin/bash

# Script: prettierDelta.sh
# Description: Runs Prettier check on Apex, LWC, and Aura component files in the delta directory

set -e

if [ -z "$1" ]; then
  echo "Error: No target directory specified."
  exit 1
fi

TARGET_DIR=$1

if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Directory '$TARGET_DIR' does not exist."
  exit 1
fi

# Find supported file types: Apex, LWC, and Aura (JavaScript, HTML, CSS)
FILES=$(find "$TARGET_DIR" -type f \( -name "*.cls" -o -name "*.trigger" -o -name "*.apex" -o -name "*.js" -o -name "*.html" -o -name "*.css" -o -name "*.cmp" -o -name "*.design" -o -name "*.auradoc" -o -name "*.svg" \))

if [ -z "$FILES" ]; then
  echo "No Apex, LWC, or Aura files found in delta. Skipping Prettier check."
  exit 0
fi

echo "Running Prettier check on these files:"
echo "$FILES"

# Run Prettier check on the found files
npx prettier --check $FILES
