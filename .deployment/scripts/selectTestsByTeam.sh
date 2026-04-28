#!/bin/bash

# selectTestsByTeam.sh
# Generic test-selection script based on changed Salesforce source folders.
# Usage: selectTestsByTeam.sh <changed_files_list> <branch_name>

set -euo pipefail

CHANGED_FILES="$1"
BRANCH_NAME="$2"

mapfile -t PACKAGE_DIRS < <(jq -r '.packageDirectories[]?.path' sfdx-project.json | sed '/^null$/d')

# Function to extract test class names from a directory
extract_test_classes() {
    local folder="$1"
    local test_classes=""
    
    # Find all test classes in the folder
    if [ -d "$folder" ]; then
        # Use find to get all .cls files and check for test annotations
        while IFS= read -r -d '' file; do
            if grep -q "@[Ii]sTest\|Test\.cls" "$file" 2>/dev/null; then
                # Extract class name from file path (remove path and .cls extension)
                class_name=$(basename "$file" .cls)
                if [ -n "$test_classes" ]; then
                    test_classes="$test_classes $class_name"
                else
                    test_classes="$class_name"
                fi
            fi
        done < <(find "$folder" -name "*.cls" -type f -print0 2>/dev/null || true)
    fi
    
    echo "$test_classes"
}

# Main logic
echo "=== Test Selection Script ==="
echo "Changed files:"
echo "$CHANGED_FILES"
echo "Branch: $BRANCH_NAME"
echo "=========================="

TEST_CLASSES=""
for folder in "${PACKAGE_DIRS[@]}"; do
    if echo "$CHANGED_FILES" | grep -q "^$folder/"; then
        folder_tests=$(extract_test_classes "$folder")
        if [ -n "$folder_tests" ]; then
            if [ -n "$TEST_CLASSES" ]; then
                TEST_CLASSES="$TEST_CLASSES $folder_tests"
            else
                TEST_CLASSES="$folder_tests"
            fi
            echo "Found $(echo "$folder_tests" | tr ' ' '\n' | wc -l) test classes in $folder"
        fi
    fi
done

# Output results
if [ -n "$TEST_CLASSES" ]; then
    TOTAL_TESTS=$(echo "$TEST_CLASSES" | tr ' ' '\n' | wc -l)
    echo "Selected $TOTAL_TESTS test classes from changed package directories"
    echo "=========================="
    echo "Running $TOTAL_TESTS specified test classes:"
    echo "$TEST_CLASSES" | tr ' ' '\n'
    if [ -n "$GITHUB_ENV" ]; then
        echo "SIT_TEST_RUN=RunSpecifiedTests" >> $GITHUB_ENV
        echo "TEST_CLASSES=$TEST_CLASSES" >> $GITHUB_ENV
    else
        export SIT_TEST_RUN=RunSpecifiedTests
        export TEST_CLASSES="$TEST_CLASSES"
    fi
    
    # Test classes will be displayed in detail during deployment validation
else
    echo "No test classes found, falling back to RunLocalTests"
    if [ -n "$GITHUB_ENV" ]; then
        echo "SIT_TEST_RUN=RunLocalTests" >> $GITHUB_ENV
        echo "TEST_CLASSES=" >> $GITHUB_ENV
    else
        export SIT_TEST_RUN=RunLocalTests
        export TEST_CLASSES=
    fi
fi

echo "=========================="
echo "Test selection completed"
