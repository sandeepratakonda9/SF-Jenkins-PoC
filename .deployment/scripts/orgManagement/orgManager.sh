#!/bin/bash
ALIAS="$1"
SETTING="$2"

#Usage      :   Call directly from GitHub workflow
#Example    :   .deployment/scripts/orgManagement/orgManager.sh SO_SNAPSHOT enableOmniSudioSettings

# Extract the login url
LOGIN_URL=$(sf org open -o "$ALIAS" --url-only --json | jq -r '.result.url')

# Check for the setting to enable
if [ $SETTING == 'enableOmniSudioSettings' ]; then
node .deployment/scripts/orgManagement/enableOmniSudioSettings.js "$LOGIN_URL"
fi