#!/bin/bash

# Script: scannerCode.sh
# Description: Runs Salesforce Code Scanner on files in the provided delta directory.

# Ensure a target directory is passed as an argument
if [ -z "$1" ]; then
  echo "Error: No target directory specified. Pass the path to the delta deployment directory."
  exit 1
fi

TARGET_DIR=$1

# Check if the target directory exists
if [ ! -d "$TARGET_DIR" ]; then
  echo "Error: Target directory '$TARGET_DIR' does not exist."
  exit 1
fi

# List files in the target directory
echo "The following files are present in '$TARGET_DIR':"
ls -R "$TARGET_DIR"

# Run Salesforce Code Scanner
echo "Running Salesforce Code Scanner on files in '$TARGET_DIR'..."
sf code-analyzer run --target "$TARGET_DIR" --view table --rule-selector pmd --severity-threshold 1

# Check the exit status of the scanner
if [ $? -eq 0 ]; then
  echo "Code scan completed successfully!"
else
  echo "Error: Code scan failed. Check the output for details."
  exit 1
fi