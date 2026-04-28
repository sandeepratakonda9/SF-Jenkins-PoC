#!/bin/bash

##############################################################################
# Script: cancelRunningDeployments.sh
# Purpose: Cancel a specific Salesforce deployment/validation for a target org
# Usage: ./cancelRunningDeployments.sh <ORG_ALIAS> <DEPLOYMENT_ID>
# Use Case: Run this when a GitHub workflow is cancelled to clean up a deployment
##############################################################################

set -e

ORG_ALIAS=$1
DEPLOYMENT_ID=$2

if [ -z "$ORG_ALIAS" ] || [ -z "$DEPLOYMENT_ID" ]; then
    echo "Usage: $0 <ORG_ALIAS> <DEPLOYMENT_ID>"
    exit 1
fi

echo "=== Attempting to cancel deployment on ${ORG_ALIAS} ==="
echo "Deployment ID: $DEPLOYMENT_ID"
echo ""

# Check if org is authenticated
if ! sf org display --target-org "$ORG_ALIAS" &> /dev/null; then
    echo "⚠️  Org ${ORG_ALIAS} is not authenticated. Skipping cancellation."
    exit 0
fi

# Validate deployment ID format (should start with 0Af)
if [[ ! "$DEPLOYMENT_ID" =~ ^0Af[a-zA-Z0-9]{15}$ ]]; then
    echo "⚠️  Invalid deployment ID format: $DEPLOYMENT_ID"
    echo "   Expected format: 0Af followed by 15 alphanumeric characters"
    exit 0
fi

# Attempt to cancel the specific deployment
echo "Cancelling deployment: $DEPLOYMENT_ID"

if sf project deploy cancel --job-id "$DEPLOYMENT_ID" --target-org "$ORG_ALIAS" 2>&1; then
    echo ""
    echo "✓ Successfully cancelled deployment: $DEPLOYMENT_ID"
    exit 0
else
    echo ""
    echo "⚠️  Failed to cancel deployment: $DEPLOYMENT_ID"
    echo "   Possible reasons:"
    echo "   - Deployment already completed"
    echo "   - Deployment ID not found"
    echo "   - Deployment not associated with this org"
    exit 0
fi

