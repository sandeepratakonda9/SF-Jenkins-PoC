#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"
FORMAT="$3"
DIRTODEPLOY="$4"
GITHUB_TOKEN="$5"
GITHUB_NUMBER="$6"

set -e

# Debug output
echo "=== Salesforce Deployment Script Debug ==="
echo "ALIAS: $ALIAS"
echo "TESTLEVEL: $TESTLEVEL"
echo "FORMAT: $FORMAT"
echo "DIRTODEPLOY: $DIRTODEPLOY"
echo "============================================"

# Deploy using sourcepath format
if [ "$FORMAT" == 'sourcepath' ] && [ ! -z "$TESTLEVEL" ]; then
    echo "Deploying from source directory: $DIRTODEPLOY"
    
    if [ "$TESTLEVEL" == "RunSpecifiedTests" ]; then
        if [ -n "$TEST_CLASSES" ]; then
            # Display selected test classes for debugging and transparency
            TOTAL_TESTS=$(echo "$TEST_CLASSES" | tr ' ' '\n' | wc -l)
            echo "Running $TOTAL_TESTS specified test classes"
            echo "---"
            
            # Start deployment and capture ID
            DEPLOY_JSON=$(sf project deploy start --source-dir $DIRTODEPLOY --target-org "$ALIAS" --ignore-conflicts --dry-run --tests $TEST_CLASSES --async --json)
            DEPLOYMENT_ID=$(echo "$DEPLOY_JSON" | jq -r '.result.id')
            echo "$DEPLOYMENT_ID" > .deployment_id_sit.txt
            echo "Deployment ID: $DEPLOYMENT_ID"
            
            # Wait for deployment to complete
            sf project deploy report --job-id "$DEPLOYMENT_ID" --target-org "$ALIAS" --wait 180 --coverage-formatters=json-summary
        else
            echo "ERROR: TESTLEVEL is RunSpecifiedTests but TEST_CLASSES is empty"
            echo "Falling back to RunLocalTests"
            
            # Start deployment and capture ID
            DEPLOY_JSON=$(sf project deploy start --source-dir $DIRTODEPLOY --target-org "$ALIAS" --ignore-conflicts --dry-run --test-level "RunLocalTests" --async --json)
            DEPLOYMENT_ID=$(echo "$DEPLOY_JSON" | jq -r '.result.id')
            echo "$DEPLOYMENT_ID" > .deployment_id_sit.txt
            echo "Deployment ID: $DEPLOYMENT_ID"
            
            # Wait for deployment to complete
            sf project deploy report --job-id "$DEPLOYMENT_ID" --target-org "$ALIAS" --wait 180 --coverage-formatters=json-summary
        fi
    else
        # echo "Running with test level: $TESTLEVEL"
        
        # Start deployment and capture ID
        # DEPLOY_JSON=$(sf project deploy start --source-dir $DIRTODEPLOY --target-org "$ALIAS" --ignore-conflicts --dry-run --test-level "$TESTLEVEL" --async --json)

        set +e

        DEPLOY_JSON=$(sf project deploy start --source-dir $DIRTODEPLOY \
            --target-org "$ALIAS" \
            --ignore-conflicts \
            --dry-run \
            --test-level "$TESTLEVEL" \
            --async \
            --json 2>&1)

        DEPLOY_EXIT_CODE=$?

        echo "=== Raw Deploy Response ==="
        echo "$DEPLOY_JSON"

        if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
            echo "Deploy start command failed!"
            exit 1
        fi

        set -e

        DEPLOYMENT_ID=$(echo "$DEPLOY_JSON" | jq -r '.result.id')
        echo "$DEPLOYMENT_ID" > .deployment_id_sit.txt
        echo "Deployment ID: $DEPLOYMENT_ID"
        
        LABELS_FILE="$DIRTODEPLOY/**/labels/CustomLabels.labels-meta.xml"

        for f in $(ls $LABELS_FILE 2>/dev/null); do
            if grep -q "<labels>" "$f" && ! grep -q "<fullName>" "$f"; then
                echo "ERROR: CustomLabels file has <labels> but no <fullName>: $f"
                exit 1
            fi
        done

        # Wait for deployment to complete
        sf project deploy report --job-id "$DEPLOYMENT_ID" --target-org "$ALIAS" --wait 180 --coverage-formatters=json-summary
    fi
    
# Deploy using manifest format
elif [ "$FORMAT" == 'manifest' ]; then
    echo "Deploying from manifest: $DIRTODEPLOY"
    
    if [ "$TESTLEVEL" == "RunSpecifiedTests" ]; then
        if [ -n "$TEST_CLASSES" ]; then
            # Display selected test classes for debugging and transparency
            TOTAL_TESTS=$(echo "$TEST_CLASSES" | tr ' ' '\n' | wc -l)
            echo "Running $TOTAL_TESTS specified test classes"
            echo "---"
            
            # Start deployment and capture ID
            DEPLOY_JSON=$(sf project deploy start --manifest $DIRTODEPLOY --target-org "$ALIAS" --ignore-conflicts --dry-run --tests $TEST_CLASSES --async --json)
            DEPLOYMENT_ID=$(echo "$DEPLOY_JSON" | jq -r '.result.id')
            echo "$DEPLOYMENT_ID" > .deployment_id_sit.txt
            echo "Deployment ID: $DEPLOYMENT_ID"
            
            # Wait for deployment to complete
            sf project deploy report --job-id "$DEPLOYMENT_ID" --target-org "$ALIAS" --wait 180 --coverage-formatters=json-summary
        else
            echo "ERROR: TESTLEVEL is RunSpecifiedTests but TEST_CLASSES is empty"
            echo "Falling back to RunLocalTests"
            
            # Start deployment and capture ID
            DEPLOY_JSON=$(sf project deploy start --manifest $DIRTODEPLOY --target-org "$ALIAS" --ignore-conflicts --dry-run --test-level "RunLocalTests" --async --json)
            DEPLOYMENT_ID=$(echo "$DEPLOY_JSON" | jq -r '.result.id')
            echo "$DEPLOYMENT_ID" > .deployment_id_sit.txt
            echo "Deployment ID: $DEPLOYMENT_ID"
            
            # Wait for deployment to complete
            sf project deploy report --job-id "$DEPLOYMENT_ID" --target-org "$ALIAS" --wait 180 --coverage-formatters=json-summary
        fi
    else
        echo "Running with test level: $TESTLEVEL"
        
        # Start deployment and capture ID
        DEPLOY_JSON=$(sf project deploy start --manifest $DIRTODEPLOY --target-org "$ALIAS" --ignore-conflicts --dry-run --test-level "$TESTLEVEL" --async --json)
        DEPLOYMENT_ID=$(echo "$DEPLOY_JSON" | jq -r '.result.id')
        echo "$DEPLOYMENT_ID" > .deployment_id_sit.txt
        echo "Deployment ID: $DEPLOYMENT_ID"
        
        # Wait for deployment to complete
        sf project deploy report --job-id "$DEPLOYMENT_ID" --target-org "$ALIAS" --wait 180 --coverage-formatters=json-summary
    fi
    
else
    echo "Invalid source deployment command"
    echo "FORMAT: $FORMAT, TESTLEVEL: $TESTLEVEL"
    exit 1
fi

# Check if deployment succeeded (sf project deploy report doesn't fail automatically)
echo ""
echo "=== Checking Deployment Status ==="
DEPLOY_STATUS=$(sf project deploy report --job-id "$DEPLOYMENT_ID" --target-org "$ALIAS" --json | jq -r '.result.status')
echo "Deployment status: $DEPLOY_STATUS"

if [ "$DEPLOY_STATUS" != "Succeeded" ]; then
    echo "ERROR: Deployment failed with status: $DEPLOY_STATUS"
    exit 1
fi

# Extract test coverage and post to GitHub PR
echo "=== Processing Test Coverage ==="
if [ -f "coverage/coverage/coverage-summary.json" ]; then
    testRunCoverage=$(cat coverage/coverage/coverage-summary.json | jq -r '.total.lines.pct')
    echo "Test coverage: $testRunCoverage%"
    
    if [ -n "$GITHUB_TOKEN" ] && [ -n "$GITHUB_NUMBER" ]; then
        echo "Posting coverage to GitHub PR #$GITHUB_NUMBER"
        curl -L \
          -X POST \
          -H "Accept: application/vnd.github+json" \
          -H "Authorization: Bearer $GITHUB_TOKEN" \
          https://git.i.mercedes-benz.com/api/v3/repos/mbfs-OneOps/T1224-OneOPS/issues/$GITHUB_NUMBER/comments \
          -d "$(jq -n --arg body "FYI: the test coverage of the validation against SIT org is: $testRunCoverage%" '{ "body": $body }')"
    else
        echo "Skipping GitHub PR comment - missing GITHUB_TOKEN or GITHUB_NUMBER"
    fi
else
    echo "WARNING: Coverage file not found at coverage/coverage/coverage-summary.json"
    echo "Skipping coverage reporting"
fi

echo "=== Deployment completed successfully ==="
