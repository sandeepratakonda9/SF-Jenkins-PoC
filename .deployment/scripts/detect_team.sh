#!/bin/bash

# Check if running inside GitHub Actions
if [ "$GITHUB_EVENT_NAME" == "pull_request" ] && [ -n "$GITHUB_EVENT_PATH" ]; then
  COMMIT_MSG=$(jq -r '.pull_request.title' "$GITHUB_EVENT_PATH")
else
  COMMIT_MSG=$(git log -1 --pretty=%B)
fi

echo "Commit message: '$COMMIT_MSG'"

PREFIX=$(echo "$COMMIT_MSG" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -oE '^[^/]+' | tr '[:upper:]' '[:lower:]')
echo "Detected prefix: '$PREFIX'"

case "$PREFIX" in
  oh)
    TEAM="OneHouse-Salesforce"
    ;;
  credit|retention|ivr|clientservices|dealermgmt)
    TEAM="OneOps"
    ;;
  *)
    TEAM="unknown"
    ;;
esac

SERVICE_NAME="$TEAM"

mkdir -p .deployment/scripts
{
  echo "TEAM=$TEAM"
  echo "SERVICE_NAME=$SERVICE_NAME"
} > .deployment/scripts/notify_team.env
