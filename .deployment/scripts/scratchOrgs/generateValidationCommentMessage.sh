#!/bin/bash

##############################################################################
# Script: generateValidationCommentMessage.sh
# Purpose: Generate PR comment message for scratch org validation decision
# Usage: ./generateValidationCommentMessage.sh <skip_validation> <reason>
#
# Args:
#   $1 - SKIP_VALIDATION (true/false)
#   $2 - SKIP_REASON (reason for decision)
#
# Output: Formatted markdown message for PR comment
##############################################################################

set -e

SKIP_VALIDATION="${1:-false}"
SKIP_REASON="${2:-Assessment completed}"

if [ "$SKIP_VALIDATION" == "true" ]; then
    # Validation was SKIPPED
    cat << EOF
### ⏭️ Scratch Org Validation SKIPPED

**Decision:** Validation skipped to save time  
**Reason:** ${SKIP_REASON}

---

✅ **SIT validation will still run** to ensure code quality.

The changes in this PR are considered low-risk:
- ✅ No deletions detected
- ✅ Settings folder unchanged
- ✅ Single folder or documentation-only changes

<details>
<summary>ℹ️ When does validation run?</summary>

Scratch org validation runs automatically when:
- Any files are deleted
- Settings folder changes (fs_dm/main/default/settings)
- Multiple folders are modified in the same PR
</details>
EOF
else
    # Validation is RUNNING
    cat << EOF
### 🔍 Scratch Org Validation RUNNING

**Decision:** Full validation required  
**Reason:** ${SKIP_REASON}

---

This PR contains changes that require comprehensive validation:
- Full scratch org creation and deployment
- SIT validation will also run

<details>
<summary>ℹ️ Why is validation required?</summary>

Validation runs when:
- **Deletions detected** - Risk of breaking dependencies
- **Settings folder changed** - Org-wide impact
- **Multiple folders changed** - Complex cross-component changes
</details>
EOF
fi

