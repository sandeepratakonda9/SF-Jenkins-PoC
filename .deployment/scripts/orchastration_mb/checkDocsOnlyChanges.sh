#!/bin/bash
set -e

# Accept optional parameters for git comparison (default to HEAD and origin/develop)
FROM_REF="${1:-origin/develop}"
TO_REF="${2:-HEAD}"

# Get all changed files between the specified refs
changed_files=$(git diff --name-only $FROM_REF $TO_REF)

# Check if there are any changed files
if [ -z "$changed_files" ]; then
    echo "FALSE"
    exit 0
fi

# Check if ALL changed files are within .deployment/ or .github/
docs_only=true
while IFS= read -r file; do
    if [[ ! "$file" =~ ^\.deployment/ ]] && [[ ! "$file" =~ ^\.github/ ]]; then
        docs_only=false
        break
    fi
done <<< "$changed_files"

# Output result
if $docs_only; then
    echo "TRUE"
else
    echo "FALSE"
fi
