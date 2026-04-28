#!/bin/bash
set -euo pipefail

# Get the pull request title
GITHUB_TOKEN="$1"
GITHUB_NUMBER="$2"
API_BASE_URL="${GITHUB_API_URL:-https://api.github.com}"

PR_TITLE=$(curl -sSL \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  "$API_BASE_URL/repos/$GITHUB_REPOSITORY/pulls/$GITHUB_NUMBER" | jq -r '.title')

echo "Your current Pull Request title is: " "$PR_TITLE"

# Get the branch name
BRANCH_NAME=$GITHUB_HEAD_REF
echo "Your current Branch name is: " $BRANCH_NAME

# Generic naming conventions:
# - Branch: team-or-scope/TICKET-1234...
# - PR: [DO NOT MERGE] optional, then same prefix and a title.
EXPECTED_BRANCH_FORMAT='^[a-zA-Z0-9._-]+/[A-Z][A-Z0-9]+-[0-9]+([/_-].*)?$'
EXPECTED_PR_FORMAT='^(\[DO NOT MERGE\]\s*)?[a-zA-Z0-9._-]+/[A-Z][A-Z0-9]+-[0-9]+(\s+.+)?$'

# Check if the pull request title matches the expected format
if [[ ! $PR_TITLE =~ $EXPECTED_PR_FORMAT ]]; then
  echo "error: Pull request title does not match expected format ([DO NOT MERGE] team/JiraKey-1234 Optional title)"
  exit 1
else
  echo "Pull request title is in the correct format"
fi

# Check if the branch name matches the expected format
if [[ ! $BRANCH_NAME =~ $EXPECTED_BRANCH_FORMAT ]]; then
  echo "error: Branch name does not match expected format (team/JiraKey-1234)"
  exit 1
else
  echo "Branch name is in the correct format"
fi

exit 0