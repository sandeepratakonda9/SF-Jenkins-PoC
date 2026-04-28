#!/bin/bash
ALIAS="$1"
TARGETORGTYPE="$2"

set -euo pipefail

# Keep compatibility with existing workflow arguments while using generic source-format deployment.
if [ "$TARGETORGTYPE" == "SCRATCHORGPLAIN" ] || [ "$TARGETORGTYPE" == "SCRATCHORGFULL" ] || [ "$TARGETORGTYPE" == "DEVOPSSANDBOX" ]; then
  TESTLEVEL="NoTestRun"
elif [ "$TARGETORGTYPE" == "RELEASETESTORG" ]; then
  TESTLEVEL="RunLocalTests"
elif [ "$TARGETORGTYPE" == "RELEASEORG" ]; then
  TESTLEVEL="RUNDEFAULT"
else
  TESTLEVEL="RunLocalTests"
fi

echo "TESTLEVEL is set to $TESTLEVEL"
echo "Resolving package directories from sfdx-project.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required but not found"
  exit 1
fi

mapfile -t SOURCE_DIRS < <(jq -r '.packageDirectories[]?.path' sfdx-project.json | sed '/^null$/d')

if [ "${#SOURCE_DIRS[@]}" -eq 0 ]; then
  echo "No packageDirectories found in sfdx-project.json"
  exit 1
fi

for dir in "${SOURCE_DIRS[@]}"; do
  if [ -d "$dir" ]; then
    .deployment/scripts/deploySourceFormat.sh "$ALIAS" "$TESTLEVEL" sourcepath "$dir"
  else
    echo "Skipping missing package directory: $dir"
  fi
done

echo -e "──────────────────────────────────────────────────────────────────────────\n\nDEPLOYMENT COMPLETED!\n\n──────────────────────────────────────────────────────────────────────────"
