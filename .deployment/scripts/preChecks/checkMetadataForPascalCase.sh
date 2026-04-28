#!/bin/bash

invalid_files_pascal_case=""

# Function to check if a filename follows PascalCase after the prefix
is_pascal_case_after_prefix() {
  local filename=$1
  # Remove the prefix (FS_, EU_, COM_, CORE_, or AT_)
  local without_prefix="${filename#FS_}"
  without_prefix="${without_prefix#EU_}"
  without_prefix="${without_prefix#COM_}"
  without_prefix="${without_prefix#CORE_}"
  without_prefix="${without_prefix#AT_}"
  # Remove the Salesforce suffixes like __c, __r, etc.
  local without_suffix="${without_prefix%%__*}"
  # Check if the first character is uppercase
  if [[ ! $without_suffix =~ ^[A-Z] ]]; then
    echo "$filename: First character is not uppercase"
    return 1
  fi
  # Check if the rest of the filename contains only alphanumeric characters
  if [[ ! $without_suffix =~ ^[A-Za-z0-9]+$ ]]; then
    echo "$filename: Contains invalid characters (non-alphanumeric)"
    return 1
  fi
  # If both checks pass, it's valid PascalCase
  return 0
}

# Iterate over all files with the .field-meta.xml extension
for f in $(find . -name "*.field-meta.xml"); do
  # Get the base name of the file
  base_name=$(basename "$f")
  # Check if the filename is PascalCase after the valid prefix
  if ! is_pascal_case_after_prefix "$base_name"; then
    invalid_files_pascal_case+="$base_name "
  fi
done

# Print invalid filenames for PascalCase
if [ -n "$invalid_files_pascal_case" ]; then
  echo "Invalid PascalCase filenames:"
  echo "$invalid_files_pascal_case"
fi

# Exit with failure if there are any invalid PascalCase filenames
if [ -n "$invalid_files_pascal_case" ]; then
  exit 1
fi