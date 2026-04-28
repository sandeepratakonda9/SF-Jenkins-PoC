#!/bin/bash

##############################################################################
# Script: assessScratchOrgValidationNeed.sh
# Purpose: Determine if scratch org validation should run based on PR changes
# Usage: ./assessScratchOrgValidationNeed.sh [delta-dir]
# 
# Returns: 
#   - Sets SKIP_SCRATCH_ORG=true/false in GITHUB_ENV
#   - Sets SKIP_REASON with explanation in GITHUB_ENV
#   - Exit 0 always (non-blocking)
#
# Logic:
#   Run validation if ANY of these conditions are met:
#   1. Deletions detected (destructiveChanges.xml exists and not empty)
#   2. Settings folder changed (fs_dm/main/default/settings)
#   3. Multiple relevant folders changed (>1 folder)
##############################################################################

set -e

DELTA_DIR="${1:-./temp-delta-deployment}"

echo "=== Assessing if Scratch Org Validation is Required ==="
echo "Analyzing delta directory: $DELTA_DIR"
echo ""

SKIP_SCRATCH_ORG="false"
SKIP_REASON=""

# List of relevant directories to check
RELEVANT_DIRS=(
    "common_frameworks"
    "core_dm"
    "fs_dm"
    "fs_bl"
    "fs_retention"
    "fs_clientServices"
    "fs_credit"
    "fs_industryCloud"
    "fs_ivr"
    "fs_post_access-mgmt"
    "fs_post_config"
    "fs_post_ui"
    "fs_dealerMgmt"
    "fs_ohCop"
    "fs_ohCmp"
    "fs_athlon"
)

# Check if delta directory exists
if [ ! -d "$DELTA_DIR" ]; then
    echo "⚠️  Delta directory not found: $DELTA_DIR"
    echo "   Defaulting to RUN validation (safe mode)"
    SKIP_SCRATCH_ORG="false"
    SKIP_REASON="Delta directory not found - running validation for safety"
    echo "SKIP_SCRATCH_ORG=$SKIP_SCRATCH_ORG" >> $GITHUB_ENV
    echo "SKIP_REASON=$SKIP_REASON" >> $GITHUB_ENV
    exit 0
fi

# ============================================================================
# CHECK 1: Are there any deletions?
# ============================================================================
echo "Check 1: Deletions"
echo "-------------------"

DESTRUCTIVE_CHANGES="$DELTA_DIR/destructiveChanges/destructiveChanges.xml"

if [ -f "$DESTRUCTIVE_CHANGES" ]; then
    # Check if destructiveChanges.xml has actual content (not just empty XML)
    DELETION_COUNT=$(grep -c "<name>" "$DESTRUCTIVE_CHANGES" 2>/dev/null || echo "0")
    
    if [ "$DELETION_COUNT" -gt 0 ]; then
        echo "✓ Deletions detected in destructiveChanges.xml ($DELETION_COUNT items)"
        echo "  → Scratch org validation REQUIRED"
        echo ""
        
        # Show what's being deleted (first 10 items)
        echo "  Deleted items:"
        grep "<name>" "$DESTRUCTIVE_CHANGES" | head -10 | sed 's/^/    /'
        if [ "$DELETION_COUNT" -gt 10 ]; then
            echo "    ... and $((DELETION_COUNT - 10)) more"
        fi
        
        SKIP_SCRATCH_ORG="false"
        SKIP_REASON="Deletions detected ($DELETION_COUNT items)"
        
        echo "SKIP_SCRATCH_ORG=$SKIP_SCRATCH_ORG" >> $GITHUB_ENV
        echo "SKIP_REASON=$SKIP_REASON" >> $GITHUB_ENV
        echo ""
        echo "=== Decision: RUN VALIDATION (Deletions) ==="
        exit 0
    else
        echo "  No deletions found (destructiveChanges.xml is empty)"
    fi
else
    echo "  No destructiveChanges.xml file - no deletions"
fi

echo ""

# ============================================================================
# CHECK 2: Did the settings folder change?
# ============================================================================
echo "Check 2: Settings Folder"
echo "------------------------"

SETTINGS_PATH="fs_dm/main/default/settings"

# Check if settings folder exists in delta
if [ -d "$DELTA_DIR/$SETTINGS_PATH" ]; then
    SETTINGS_FILE_COUNT=$(find "$DELTA_DIR/$SETTINGS_PATH" -type f | wc -l | xargs)
    
    if [ "$SETTINGS_FILE_COUNT" -gt 0 ]; then
        echo "✓ Settings folder changed: $SETTINGS_PATH"
        echo "  Files changed: $SETTINGS_FILE_COUNT"
        echo "  → Scratch org validation REQUIRED"
        
        # Show which settings files changed
        echo ""
        echo "  Changed settings files:"
        find "$DELTA_DIR/$SETTINGS_PATH" -type f -name "*.xml" | head -5 | sed 's|'"$DELTA_DIR/"'|    |'
        
        SKIP_SCRATCH_ORG="false"
        SKIP_REASON="Settings folder changed ($SETTINGS_FILE_COUNT files)"
        
        echo "SKIP_SCRATCH_ORG=$SKIP_SCRATCH_ORG" >> $GITHUB_ENV
        echo "SKIP_REASON=$SKIP_REASON" >> $GITHUB_ENV
        echo ""
        echo "=== Decision: RUN VALIDATION (Settings) ==="
        exit 0
    fi
else
    echo "  Settings folder unchanged"
fi

echo ""

# ============================================================================
# CHECK 3: How many relevant folders are affected?
# ============================================================================
echo "Check 3: Multiple Folders"
echo "-------------------------"
echo "Note: Only checking Salesforce metadata folders (RELEVANT_DIRS)"
echo "      Changes to .deployment, .github, docs, etc. are ignored"
echo ""

AFFECTED_DIRS=()

# Only loop through RELEVANT_DIRS - explicitly excluding .deployment, .github, etc.
for dir in "${RELEVANT_DIRS[@]}"; do
    if [ -d "$DELTA_DIR/$dir" ]; then
        # Check if there are actual files in this directory
        FILE_COUNT=$(find "$DELTA_DIR/$dir" -type f 2>/dev/null | wc -l | xargs)
        if [ "$FILE_COUNT" -gt 0 ]; then
            AFFECTED_DIRS+=("$dir")
            echo "  ✓ Found changes in: $dir ($FILE_COUNT files)"
        fi
    fi
done

# Show what folders exist in delta but are being ignored
echo ""
echo "Checking for non-relevant folders (will be ignored):"
for ignored_dir in ".deployment" ".github" "config" "docs" ".vscode" ".idea"; do
    if [ -d "$DELTA_DIR/$ignored_dir" ]; then
        IGNORED_FILE_COUNT=$(find "$DELTA_DIR/$ignored_dir" -type f 2>/dev/null | wc -l | xargs)
        if [ "$IGNORED_FILE_COUNT" -gt 0 ]; then
            echo "  ⊘ Ignoring: $ignored_dir ($IGNORED_FILE_COUNT files) - not a Salesforce metadata folder"
        fi
    fi
done

AFFECTED_COUNT=${#AFFECTED_DIRS[@]}
echo ""
echo "Total relevant Salesforce folders affected: $AFFECTED_COUNT"
echo "  (Only counting folders from RELEVANT_DIRS list)"

if [ $AFFECTED_COUNT -eq 0 ]; then
    echo "  No relevant folders changed"
    echo ""
    echo "⚠️  No Salesforce metadata folders affected"
    echo "   Possible documentation/config-only changes"
    echo "   → Scratch org validation will be SKIPPED"
    
    SKIP_SCRATCH_ORG="true"
    SKIP_REASON="No relevant Salesforce folders changed (doc/config only)"
    
elif [ $AFFECTED_COUNT -eq 1 ]; then
    echo "  Only 1 folder affected: ${AFFECTED_DIRS[0]}"
    echo ""
    echo "✓ Single folder change detected - low risk"
    echo "  → Scratch org validation will be SKIPPED"
    
    SKIP_SCRATCH_ORG="true"
    SKIP_REASON="Single folder change only (${AFFECTED_DIRS[0]})"
    
else
    echo "  Multiple folders affected: ${AFFECTED_DIRS[*]}"
    echo ""
    echo "✓ Multiple folders changed ($AFFECTED_COUNT folders)"
    echo "  → Scratch org validation REQUIRED"
    
    SKIP_SCRATCH_ORG="false"
    SKIP_REASON="Multiple folders changed: ${AFFECTED_DIRS[*]}"
fi

# ============================================================================
# Final Decision
# ============================================================================
echo ""
echo "=== Decision ==="
echo "SKIP_SCRATCH_ORG: $SKIP_SCRATCH_ORG"
echo "Reason: $SKIP_REASON"
echo ""

if [ "$SKIP_SCRATCH_ORG" == "true" ]; then
    echo "🎉 Scratch Org validation will be SKIPPED"
    echo "   Estimated time saved: ~2+ hours"
    echo "   SIT validation will still run for code quality checks"
else
    echo "🔍 Scratch Org validation will RUN"
    echo "   Changes require full validation for safety"
fi

echo ""

# Set environment variables for GitHub Actions
echo "SKIP_SCRATCH_ORG=$SKIP_SCRATCH_ORG" >> $GITHUB_ENV
echo "SKIP_REASON=$SKIP_REASON" >> $GITHUB_ENV

exit 0

