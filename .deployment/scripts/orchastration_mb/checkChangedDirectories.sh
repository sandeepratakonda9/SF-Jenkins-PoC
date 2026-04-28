#!/bin/bash
set -euo pipefail

DELTA_DIR="./temp-delta-deployment"

if [ ! -d "$DELTA_DIR" ] || [ ! -f "sfdx-project.json" ]; then
  echo "FALSE"
  exit 0
fi

mapfile -t package_dirs < <(jq -r '.packageDirectories[]?.path' sfdx-project.json | sed '/^null$/d')
if [ "${#package_dirs[@]}" -eq 0 ]; then
  echo "FALSE"
  exit 0
fi

for dir in "${package_dirs[@]}"; do
  if [ -d "$DELTA_DIR/$dir" ]; then
    echo "TRUE"
    exit 0
  fi
done

echo "FALSE"
