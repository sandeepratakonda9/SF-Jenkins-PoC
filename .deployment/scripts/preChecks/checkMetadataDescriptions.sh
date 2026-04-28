#!/bin/bash

# Exit immediately if any command exits with a non-zero status
set -e

# Temp remove irrelevant paths where the description rule is not applied.
# Use -f so missing legacy paths in demo repos do not fail prechecks.
rm -rf .deployment/files \
  core_dm \
  fs_dm/main/default/tabs/et4ae5__IndividualEmailResult__c.tab-meta.xml \
  fs_dealerMgmt \
  fs_ohCop/main/default/experiences \
  fs_ohCmp/fs_collections/main/default/experiences


invalid_files=""

for file in $(find . -name "*.app-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.approvalProcess-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.cmp-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.connectedApp-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.customPermission-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done


for file in $(find . -name "*.duplicateRule-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*__c.field-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name ".flexipage-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name ".flow-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.globalValueSet-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.lightningExperienceTheme-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.matchingRule-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*__c.object-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.permissionsetgroup-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.permissionset-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name ".quickAction-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.resource-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.site-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.tab-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name "*.validationRule-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

for file in $(find . -name ".workflow-meta.xml"); do
  if ! grep -qPzo '<description>[\s\S]*<\/description>' "$file"; then
    invalid_files="$invalid_files\n$file"
  fi
done

if [ -n "$invalid_files" ]; then
  echo -e "Error: The following XML files do not have a valid description:\n$invalid_files"
  exit 1
else
  echo "No violations of description checks found"
fi