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

# Supported formats:
# 1) Jira-style (strict): team/JiraKey-1234...
# 2) Demo-friendly gitflow-style branches: feature/*, bugfix/*, hotfix/*, chore/*, release/*
STRICT_BRANCH_FORMAT='^[a-zA-Z0-9._-]+/[A-Z][A-Z0-9]+-[0-9]+([/_-].*)?$'
DEMO_BRANCH_FORMAT='^(feature|bugfix|hotfix|chore|release)/[a-zA-Z0-9._/-]+$'

# Basic PR title requirement for demo: non-empty, minimum 8 chars.
if [[ -z "${PR_TITLE// }" ]] || [[ ${#PR_TITLE} -lt 8 ]]; then
  echo "error: Pull request title must be at least 8 characters."
  exit 1
else
  echo "Pull request title is valid"
fi

# Branch name can satisfy either strict Jira format or demo gitflow format.
if [[ $BRANCH_NAME =~ $STRICT_BRANCH_FORMAT ]] || [[ $BRANCH_NAME =~ $DEMO_BRANCH_FORMAT ]]; then
  echo "Branch name is valid"
else
  echo "error: Branch name must match either 'team/JiraKey-1234' or 'feature|bugfix|hotfix|chore|release/<name>'."
  exit 1
fi

exit 0