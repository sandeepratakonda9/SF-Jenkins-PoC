# PR Comment Implementation - Clean Architecture

## Overview
The scratch org validation decision is now automatically posted as a comment to each PR, using a clean, modular architecture that keeps the workflow file minimal.

---

## Architecture

### Clean Separation of Concerns

```
┌─────────────────────────────────────────────────────────────┐
│ Workflow (.github/workflows/PR_Validation.yml)             │
│ - Orchestrates jobs                                         │
│ - Passes data between jobs                                  │
│ - Minimal logic                                             │
└───────────────┬─────────────────────────────────────────────┘
                │
                ├──> Job 1: validateAgainstScratchOrg
                │    ├─ Generate delta
                │    ├─ Run: assessScratchOrgValidationNeed.sh
                │    └─ Output: skip_validation, skip_reason
                │
                └──> Job 2: postValidationDecision
                     ├─ Run: generateValidationCommentMessage.sh
                     ├─ Add workflow link
                     └─ Post via GitHub API
```

---

## Components

### 1. Assessment Script
**File:** `.deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh`

**Purpose:** Analyze delta and determine if validation should run

**Inputs:**
- Delta directory path

**Outputs:**
- `SKIP_SCRATCH_ORG` (true/false)
- `SKIP_REASON` (explanation)

**Logic:**
- Checks `destructiveChanges.xml` for deletions
- Checks if settings folder changed
- Counts affected folders

---

### 2. Message Generation Script
**File:** `.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh`

**Purpose:** Generate formatted markdown message for PR comment

**Inputs:**
- `$1` - skip_validation (true/false)
- `$2` - skip_reason (string)

**Output:**
- Formatted markdown message to stdout

**Features:**
- Conditional formatting based on decision
- Includes emojis and structured layout
- Expandable details section

---

### 3. Workflow Orchestration
**File:** `.github/workflows/PR_Validation.yml`

**Job 1: `validateAgainstScratchOrg`**
```yaml
outputs:
  skip_validation: ${{ steps.assess-validation.outputs.skip_validation }}
  skip_reason: ${{ steps.assess-validation.outputs.skip_reason }}

steps:
  - Generate delta
  - Run assessment script
  - Export outputs
```

**Job 2: `postValidationDecision`**
```yaml
needs: [validateAgainstScratchOrg]
if: always()

steps:
  - Checkout
  - Run message generation script
  - Post comment via GitHub API
```

---

## Benefits

### ✅ Clean Workflow File
- **Before:** ~60 lines of inline message template
- **After:** ~15 lines calling scripts
- **Reduction:** 75% cleaner

### ✅ Easy to Maintain
- Edit bash scripts, not YAML
- No complex YAML expressions
- Clear separation of concerns

### ✅ Testable
```bash
# Test assessment
.deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh ./test-delta

# Test message generation
.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh true "Single folder"
```

### ✅ Reusable
- Scripts can be used in other workflows
- Message generation can be used in CLI tools
- Logic is portable

### ✅ Maintainable
- Modify messages without touching workflow
- Add custom fields easily
- Clear file structure

---

## File Structure

```
.github/workflows/
└── PR_Validation.yml                    (orchestration - minimal logic)

.deployment/scripts/scratchOrgs/
├── assessScratchOrgValidationNeed.sh   (business logic)
└── generateValidationCommentMessage.sh (presentation logic)

.deployment/docs/
├── PR_COMMENT_IMPLEMENTATION.md        (this file)
├── PR_COMMENT_EXAMPLES.md              (visual examples)
└── SCRATCH_ORG_SKIP_LOGIC.md          (assessment logic docs)
```

---

## Example Workflow Execution

### Step-by-Step Flow

```
1. Developer pushes to PR #123
   └─> Workflow triggered

2. Job: validateAgainstScratchOrg
   ├─ Generate delta (5 seconds)
   ├─ Run assessScratchOrgValidationNeed.sh (1 second)
   │  └─> Output: skip_validation=true, skip_reason="Single folder (fs_dm)"
   ├─ Skip scratch org creation
   └─> Job completes

3. Job: postValidationDecision (always runs)
   ├─ Run generateValidationCommentMessage.sh true "Single folder (fs_dm)"
   │  └─> Returns formatted markdown
   ├─ Add workflow link
   └─ Post comment to PR #123

4. Developer sees comment:
   "⏭️ Scratch Org Validation SKIPPED
    Reason: Single folder change only (fs_dm)
    Time saved: 2+ hours"
```

---

## Code Examples

### Calling Assessment Script

```bash
# From workflow
chmod +x .deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh
.deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh ./temp-delta-deployment

# Outputs are set in GITHUB_ENV:
# SKIP_SCRATCH_ORG=true/false
# SKIP_REASON="explanation"
```

### Calling Message Generation Script

```bash
# From workflow
chmod +x .deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh
MESSAGE=$(.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh "true" "Single folder")

# Returns markdown to stdout
```

### Posting Comment

```javascript
// From workflow (github-script)
const { execSync } = require('child_process');

const message = execSync(
  './scripts/generateValidationCommentMessage.sh "true" "Single folder"',
  { encoding: 'utf-8' }
);

await github.rest.issues.createComment({
  issue_number: pr_number,
  owner: context.repo.owner,
  repo: context.repo.repo,
  body: message + workflowLink
});
```

---

## Testing

### Unit Testing

Test each component independently:

```bash
# Test assessment (needs delta directory)
sf sgd source delta --from "origin/develop" --to "HEAD" \
  --output-dir ./test-delta --generate-delta
.deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh ./test-delta

# Test message generation
.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh true "Test reason"
.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh false "Test reason"
```

### Integration Testing

Test the full workflow:

1. Create test PR
2. Push commit
3. Check Actions tab for workflow run
4. Verify comment appears on PR
5. Check comment content matches expectations

---

## Customization Examples

### Add Team Information

Edit `generateValidationCommentMessage.sh`:

```bash
# Add after "Decision:" line
**Team:** ${TEAM_NAME:-Unknown}
```

Then pass team as argument:

```yaml
# In workflow
run: |
  TEAM=$(detect-team-from-files.sh)
  .deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh \
    "${{ needs.validateAgainstScratchOrg.outputs.skip_validation }}" \
    "${{ needs.validateAgainstScratchOrg.outputs.skip_reason }}" \
    "$TEAM"
```

### Add File Count

```bash
# In generateValidationCommentMessage.sh
FILE_COUNT=$(find ./temp-delta-deployment -type f | wc -l)

cat << EOF
**Files changed:** ${FILE_COUNT}
EOF
```

### Change Message Format

```bash
# Make it more concise
cat << EOF
🚀 **Validation Decision:** ${DECISION}
📝 **Reason:** ${SKIP_REASON}
⏱️ **Time:** ${TIME}
EOF
```

---

## Comparison: Before vs After

### Before (Inline in Workflow)

```yaml
- name: Post comment
  uses: actions/github-script@v6
  with:
    script: |
      const skip = process.env.SKIP_SCRATCH_ORG === 'true';
      const reason = process.env.SKIP_REASON;
      let message;
      
      if (skip) {
        message = `### ⏭️ Scratch Org Validation SKIPPED
        
        **Decision:** Validation skipped...
        [40+ more lines of template]
        `;
      } else {
        message = `### 🔍 Scratch Org Validation RUNNING
        
        **Decision:** Full validation...
        [40+ more lines of template]
        `;
      }
      
      await github.rest.issues.createComment({...});
```

**Issues:**
- ❌ Hard to read
- ❌ Hard to maintain
- ❌ Can't test locally
- ❌ Workflow file bloated

---

### After (Script-Based)

**Workflow:**
```yaml
- name: Generate and post comment
  uses: actions/github-script@v6
  with:
    script: |
      const { execSync } = require('child_process');
      
      const message = execSync(
        `.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh "${{ needs.validateAgainstScratchOrg.outputs.skip_validation }}" "${{ needs.validateAgainstScratchOrg.outputs.skip_reason }}"`,
        { encoding: 'utf-8' }
      );
      
      await github.rest.issues.createComment({...});
```

**Script** (separate file):
```bash
#!/bin/bash
SKIP_VALIDATION="${1}"
SKIP_REASON="${2}"

if [ "$SKIP_VALIDATION" == "true" ]; then
    cat << EOF
### ⏭️ Scratch Org Validation SKIPPED
[formatted message]
EOF
else
    cat << EOF
### 🔍 Scratch Org Validation RUNNING
[formatted message]
EOF
fi
```

**Benefits:**
- ✅ Clean workflow
- ✅ Easy to maintain
- ✅ Testable locally
- ✅ Reusable

---

## Future Enhancements

### Possible Improvements

1. **Reaction Emojis**
   ```javascript
   // Add thumbs up to comment
   await github.rest.reactions.createForIssueComment({
     comment_id: comment.id,
     content: '+1'
   });
   ```

2. **Update Instead of New Comment**
   ```javascript
   // Find existing comment and update it
   const comments = await github.rest.issues.listComments({...});
   const existingComment = comments.data.find(c => 
     c.body.includes('Scratch Org Validation')
   );
   
   if (existingComment) {
     await github.rest.issues.updateComment({...});
   } else {
     await github.rest.issues.createComment({...});
   }
   ```

3. **Thread Replies**
   ```javascript
   // Reply to original comment with results
   await github.rest.issues.createComment({
     body: `✅ Validation completed successfully!`,
     in_reply_to: originalCommentId
   });
   ```

4. **Rich Status Badges**
   ```markdown
   ![Status](https://img.shields.io/badge/validation-skipped-green)
   ```

---

## Troubleshooting

### Comment Not Appearing

**Check:**
1. Job ran: `if: always()` condition
2. Script executed: Check workflow logs
3. Permissions: `GITHUB_TOKEN` has `issues: write`

**Debug:**
```yaml
- name: Debug
  run: |
    echo "Skip: ${{ needs.validateAgainstScratchOrg.outputs.skip_validation }}"
    echo "Reason: ${{ needs.validateAgainstScratchOrg.outputs.skip_reason }}"
```

### Wrong Message Content

**Verify:**
1. Assessment script output is correct
2. Message generation script works locally
3. Outputs are being passed correctly

**Test:**
```bash
# Test locally with actual values
.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh "true" "Single folder (fs_dm)"
```

---

## Summary

| Aspect | Value |
|--------|-------|
| **Workflow lines** | ~15 (was ~60) |
| **Maintainability** | High - edit scripts, not YAML |
| **Testability** | Easy - run scripts locally |
| **Reusability** | High - scripts usable elsewhere |
| **Developer visibility** | Excellent - PR comments |
| **Clean architecture** | ✅ Separation of concerns |

---

**Implemented:** Dec 4, 2025  
**Version:** 1.0  
**Status:** ✅ Production Ready

