#!/bin/bash

# selectTestsByTeam.sh
# Script to determine which test classes to run based on changed files and team ownership
# Usage: selectTestsByTeam.sh <changed_files_list> <branch_name>

set -e

CHANGED_FILES="$1"
BRANCH_NAME="$2"

# Define team folders
ONEOPS_FOLDERS=("fs_credit" "fs_retention" "fs_clientServices" "fs_ivr" "fs_bl" "fs_dealerMgmt")
ONEHOUSE_FOLDERS=("fs_ohCop" "fs_ohCmp")
ATHLON_FOLDERS=("fs_athlon")

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

# Function to check if any files in the changed list belong to a folder
has_changes_in_folder() {
    local folder="$1"
    local changed_files="$2"
    
    echo "$changed_files" | grep -q "^$folder/" && return 0 || return 1
}

# Determine team based on branch name pattern (existing logic)
determine_team_from_branch() {
    local branch="$1"
    
    if [[ "$branch" == oh/COP* ]] || [[ "$branch" == oh/CHA* ]] || [[ "$branch" == oh/* ]]; then
        echo "ONEHOUSE"
    else
        echo "ONEOPS"
    fi
}

# Determine team based on changed files
determine_team_from_changes() {
    local changed_files="$1"
    local oneops_changes=false
    local onehouse_changes=false
    local athlon_changes=false
    
    # Check for OneOps changes
    for folder in "${ONEOPS_FOLDERS[@]}"; do
        if has_changes_in_folder "$folder" "$changed_files"; then
            oneops_changes=true
            break
        fi
    done
    
    # Check for OneHouse changes
    for folder in "${ONEHOUSE_FOLDERS[@]}"; do
        if has_changes_in_folder "$folder" "$changed_files"; then
            onehouse_changes=true
            break
        fi
    done
    
    # Check for Athlon changes
    for folder in "${ATHLON_FOLDERS[@]}"; do
        if has_changes_in_folder "$folder" "$changed_files"; then
            athlon_changes=true
            break
        fi
    done
    
    # Determine team based on changes - prioritize single team detection
    if [ "$athlon_changes" == true ]; then
        if [ "$oneops_changes" == true ] || [ "$onehouse_changes" == true ]; then
            echo "MIXED"
        else
            echo "ATHLON"
        fi
    elif [ "$oneops_changes" == true ] && [ "$onehouse_changes" == true ]; then
        echo "BOTH"
    elif [ "$oneops_changes" == true ]; then
        echo "ONEOPS"
    elif [ "$onehouse_changes" == true ]; then
        echo "ONEHOUSE"
    else
        echo "NONE"
    fi
}

# Main logic
echo "=== Test Selection Script ==="
echo "Changed files:"
echo "$CHANGED_FILES"
echo "Branch: $BRANCH_NAME"
echo "=========================="

# Determine team from branch and changes
TEAM_FROM_BRANCH=$(determine_team_from_branch "$BRANCH_NAME")
TEAM_FROM_CHANGES=$(determine_team_from_changes "$CHANGED_FILES")

echo "Team from branch pattern: $TEAM_FROM_BRANCH"
echo "Team from changed files: $TEAM_FROM_CHANGES"

# Final team determination - prioritize changes over branch pattern
FINAL_TEAM="$TEAM_FROM_CHANGES"
if [ "$TEAM_FROM_CHANGES" == "NONE" ]; then
    FINAL_TEAM="$TEAM_FROM_BRANCH"
fi

echo "Final team determination: $FINAL_TEAM"

# Generate test class list based on team
TEST_CLASSES=""
case "$FINAL_TEAM" in
    "ONEOPS")
        echo "Selecting OneOps test classes..."
        for folder in "${ONEOPS_FOLDERS[@]}"; do
            folder_tests=$(extract_test_classes "$folder")
            if [ -n "$folder_tests" ]; then
                if [ -n "$TEST_CLASSES" ]; then
                    TEST_CLASSES="$TEST_CLASSES $folder_tests"
                else
                    TEST_CLASSES="$folder_tests"
                fi
                echo "Found $(echo $folder_tests | tr ' ' '\n' | wc -l) test classes in $folder"
            fi
        done
        ;;
    "ONEHOUSE")
        echo "Selecting OneHouse test classes..."
        for folder in "${ONEHOUSE_FOLDERS[@]}"; do
            folder_tests=$(extract_test_classes "$folder")
            if [ -n "$folder_tests" ]; then
                if [ -n "$TEST_CLASSES" ]; then
                    TEST_CLASSES="$TEST_CLASSES $folder_tests"
                else
                    TEST_CLASSES="$folder_tests"
                fi
                echo "Found $(echo $folder_tests | tr ' ' '\n' | wc -l) test classes in $folder"
            fi
        done
        ;;
    "BOTH")
        echo "Changes in both OneOps and OneHouse folders - selecting all relevant test classes..."
        # Include both teams' test classes
        for folder in "${ONEOPS_FOLDERS[@]}" "${ONEHOUSE_FOLDERS[@]}"; do
            folder_tests=$(extract_test_classes "$folder")
            if [ -n "$folder_tests" ]; then
                if [ -n "$TEST_CLASSES" ]; then
                    TEST_CLASSES="$TEST_CLASSES $folder_tests"
                else
                    TEST_CLASSES="$folder_tests"
                fi
                echo "Found $(echo $folder_tests | tr ' ' '\n' | wc -l) test classes in $folder"
            fi
        done
        ;;
    "ATHLON")
        echo "Selecting Athlon test classes only..."
        for folder in "${ATHLON_FOLDERS[@]}"; do
            folder_tests=$(extract_test_classes "$folder")
            if [ -n "$folder_tests" ]; then
                if [ -n "$TEST_CLASSES" ]; then
                    TEST_CLASSES="$TEST_CLASSES $folder_tests"
                else
                    TEST_CLASSES="$folder_tests"
                fi
                echo "Found $(echo $folder_tests | tr ' ' '\n' | wc -l) test classes in $folder"
            fi
        done
        ;;
    "MIXED")
        echo "Changes across multiple teams - selecting all relevant test classes..."
        # Include all teams' test classes
        for folder in "${ONEOPS_FOLDERS[@]}" "${ONEHOUSE_FOLDERS[@]}" "${ATHLON_FOLDERS[@]}"; do
            folder_tests=$(extract_test_classes "$folder")
            if [ -n "$folder_tests" ]; then
                if [ -n "$TEST_CLASSES" ]; then
                    TEST_CLASSES="$TEST_CLASSES $folder_tests"
                else
                    TEST_CLASSES="$folder_tests"
                fi
                echo "Found $(echo $folder_tests | tr ' ' '\n' | wc -l) test classes in $folder"
            fi
        done
        ;;
    *)
        echo "No team-specific changes detected, falling back to RunLocalTests"
        if [ -n "$GITHUB_ENV" ]; then
            echo "SIT_TEST_RUN=RunLocalTests" >> $GITHUB_ENV
            echo "TEST_CLASSES=" >> $GITHUB_ENV
        else
            export SIT_TEST_RUN=RunLocalTests
            export TEST_CLASSES=
        fi
        exit 0
        ;;
esac

# Output results
if [ -n "$TEST_CLASSES" ]; then
    TOTAL_TESTS=$(echo "$TEST_CLASSES" | tr ' ' '\n' | wc -l)
    echo "Selected $TOTAL_TESTS test classes for $FINAL_TEAM team"
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
