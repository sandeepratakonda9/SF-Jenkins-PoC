#!/bin/bash
ALIAS="$1"
GITHUB_TOKEN="$2"
GITHUB_NUMBER="$3"

set -euo pipefail

scratchOrgLoginURL=$(sf org open -o $ALIAS --url-only --json | jq -r '.result.url')
echo $scratchOrgLoginURL


API_BASE_URL="${GITHUB_API_URL:-https://api.github.com}"

curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  "$API_BASE_URL/repos/$GITHUB_REPOSITORY/issues/$GITHUB_NUMBER/comments" \
  -d "$(jq -n --arg body "DEPLOYMENT TO SCRATCH ORG SUCCESSFUL! --- REVIEW & TEST: to open the created Scratch org and test your changes in a safe & clean environment, click on this login URL: $scratchOrgLoginURL --- --- This org will exist for 1 day. Run another successful validation to create a new org." '{ "body": $body }')"