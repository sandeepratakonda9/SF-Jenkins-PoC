#!/bin/bash

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

invalid_files_prefix=""

# Function to check if a filename starts with FS_, EU_, COM_, CORE_, DEP_, or AT_
is_valid_prefix() {
  local filename=$1
  # Check if the filename starts with FS_, EU_, COM_, CORE_, DEP_, or AT_
  if [[ $filename =~ ^(FS_|EU_|COM_|CORE_|AT_|DEP_) ]]; then
    return 0
  else
    return 1
  fi
}

# Iterate over all files with the __c.field-meta.xml extension in the target directory
for files in $(find "$TARGET_DIR" -name "*__c.field-meta.xml"); do
  # Get the base name of the file
  base_name=$(basename "$files")
  # Check if the filename starts with a valid prefix
  if ! is_valid_prefix "$base_name"; then
    invalid_files_prefix+="$base_name "
  fi
done

# Print invalid filenames for prefix
if [ -n "$invalid_files_prefix" ]; then
  echo "Invalid prefix filenames:"
  echo "$invalid_files_prefix"
  echo "--- The above script failed due to the found files which are not following the naming conventions! ---"
  exit 1
fi

echo "--- All files have valid prefixes! ---"
