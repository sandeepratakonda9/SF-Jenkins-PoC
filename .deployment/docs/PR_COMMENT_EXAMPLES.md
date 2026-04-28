# PR Comment Examples - Scratch Org Validation Decision

## Overview
The workflow automatically posts a comment to each PR explaining whether scratch org validation was skipped or is running, along with the reason.

---

## Example 1: Validation SKIPPED (Single Folder)

### Comment Posted to PR:

---

### ⏭️ Scratch Org Validation SKIPPED

**Decision:** Validation skipped to save time  
**Reason:** Single folder change only (fs_dm) 

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

🔗 [View workflow run](https://github.com/your-org/repo/actions/runs/123456)

---

## Example 2: Validation RUNNING (Deletions)

### Comment Posted to PR:

---

### 🔍 Scratch Org Validation RUNNING

**Decision:** Full validation required  
**Reason:** Deletions detected (3 items)

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

🔗 [View workflow run](https://github.com/your-org/repo/actions/runs/123456)

---

## Example 3: Validation RUNNING (Settings Folder)

### Comment Posted to PR:

---

### 🔍 Scratch Org Validation RUNNING

**Decision:** Full validation required  
**Reason:** Settings folder changed (5 files)

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

🔗 [View workflow run](https://github.com/your-org/repo/actions/runs/123456)

---

## Example 4: Validation RUNNING (Multiple Folders)

### Comment Posted to PR:

---

### 🔍 Scratch Org Validation RUNNING

**Decision:** Full validation required  
**Reason:** Multiple folders changed: fs_dm fs_bl fs_credit

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

🔗 [View workflow run](https://github.com/your-org/repo/actions/runs/123456)

---

## Example 5: Validation SKIPPED (Documentation Only)

### Comment Posted to PR:

---

### ⏭️ Scratch Org Validation SKIPPED

**Decision:** Validation skipped to save time  
**Reason:** No relevant Salesforce folders changed (doc/config only)  
**Time saved:** Approximately 2+ hours ⏱️

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

🔗 [View workflow run](https://github.com/your-org/repo/actions/runs/123456)

---

## Comment Features

### 📱 Always Included
- ✅ Clear emoji indicator (⏭️ for skip, 🔍 for run)
- ✅ Decision summary
- ✅ Specific reason from assessment
- ✅ Time estimate/savings
- ✅ Link to workflow run

### 📋 Conditional Content
- When **SKIPPED**: Shows what conditions were checked and passed
- When **RUNNING**: Explains why validation is necessary
- Expandable details section with validation criteria

### 🎨 Visual Design
- Clear heading with emoji
- Structured information (Decision/Reason/Time)
- Horizontal dividers for readability
- Collapsible details section to avoid clutter
- Direct link to see full workflow logs

---

## Benefits

### For Developers 👨‍💻
- **Immediate visibility** - Know right away if validation is running
- **Clear reasoning** - Understand why the decision was made
- **Time awareness** - Know how long to expect
- **Learning tool** - Understand what triggers validation

### For Reviewers 👀
- **Quick assessment** - See if full validation ran
- **Risk awareness** - Understand the scope of changes
- **Confidence** - Know validation criteria were checked

### For Team Leads 📊
- **Transparency** - All decisions documented in PR
- **Audit trail** - Easy to see validation history
- **Efficiency metrics** - Track time savings across PRs

---

## Customization

### Modify Comment Content

Edit the message generation script (much easier than editing YAML!):

```bash
# In: .deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh
# Modify the cat << EOF blocks for skipped or running messages
```

### Test Message Locally

You can see exactly what the comment will look like:

```bash
# Test SKIP message
.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh true "Single folder change only (fs_dm)"

# Test RUN message
.deployment/scripts/scratchOrgs/generateValidationCommentMessage.sh false "Deletions detected (3 items)"
```

### Disable Comments

To turn off PR comments temporarily:

```yaml
# In: .github/workflows/PR_Validation.yml
# Find the postValidationDecision job and change:
if: false  # Changed from: if: always()
```

### Add Custom Fields

Edit the script to add more information:

```bash
# In generateValidationCommentMessage.sh
cat << EOF
### 🔍 Scratch Org Validation RUNNING

**Decision:** Full validation required
**Reason:** ${SKIP_REASON}
**Team:** OneOps  # Add custom field
**Files changed:** 15  # Add custom field
**Estimated time:** Approximately 2+ hours ⏱️
...
EOF
```

---

## Implementation Details

### How It Works

The comment system uses a clean, modular approach:

1. **Assessment** (`validateAgainstScratchOrg` job)
   - Runs `assessScratchOrgValidationNeed.sh`
   - Outputs `skip_validation` and `skip_reason`

2. **Message Generation** (`postValidationDecision` job)
   - Uses `generateValidationCommentMessage.sh`
   - Takes decision and reason as inputs
   - Generates formatted markdown

3. **Comment Posting** (same job)
   - Uses `actions/github-script@v6`
   - Adds workflow link
   - Posts to PR via GitHub API

### Key Files

```
.deployment/scripts/scratchOrgs/
├── assessScratchOrgValidationNeed.sh     (Logic)
└── generateValidationCommentMessage.sh   (Formatting)

.github/workflows/
└── PR_Validation.yml                     (Orchestration)
```

### Benefits of This Approach

✅ **Clean workflow** - No inline message templates  
✅ **Reusable script** - Message generation can be used elsewhere  
✅ **Easy to modify** - Edit bash script, not YAML  
✅ **Testable locally** - Run script to see output  

### When Comment is Posted
- **Timing:** After scratch org job completes (or fails)
- **Condition:** `if: always()` - Posts even if validation fails
- **Token:** Uses `GITHUB_TOKEN` (automatic)

### Comment Update Strategy
- **New comment every time** - No updates to existing comments
- **Visible history** - Can see if decision changed between pushes
- **No spam** - Only one comment per workflow run

### Permissions Required
- `issues: write` - To post comments (included in default `GITHUB_TOKEN`)

---

## Example Workflow Timeline

```
PR #123 Timeline:

10:00 AM - Developer pushes commit A
10:01 AM - Workflow starts
10:02 AM - Delta generated
10:02 AM - Assessment runs
10:02 AM - 💬 Comment posted: "⏭️ Validation SKIPPED (single folder)"
10:03 AM - Workflow completes

11:00 AM - Developer pushes commit B (with deletion)
11:01 AM - Workflow starts
11:02 AM - Delta generated
11:02 AM - Assessment runs
11:02 AM - 💬 Comment posted: "🔍 Validation RUNNING (deletions detected)"
11:03 AM - Scratch org creation starts
13:05 PM - Workflow completes

Result: PR has 2 comments showing validation history
```

---

## Troubleshooting

### Comment Not Appearing?

**Check:**
1. Workflow has `issues: write` permission
2. Step isn't being skipped due to condition
3. GitHub token is valid

**Debug:**
```yaml
- name: Debug comment
  run: |
    echo "PR Number: ${{ github.event.pull_request.number }}"
    echo "Skip validation: $SKIP_SCRATCH_ORG"
    echo "Reason: $SKIP_REASON"
```

### Comment Shows Wrong Information?

**Verify:**
1. Environment variables are set correctly by assessment script
2. Script completed successfully
3. Check workflow logs for assessment output

---

## Future Enhancements

Potential improvements:
1. **Update single comment** instead of creating new ones
2. **Add reaction emojis** to the comment (👍/👎)
3. **Thread replies** with validation results after completion
4. **Status badges** showing validation status
5. **Comparison table** showing before/after stats

---

**Created:** Dec 4, 2025  
**Version:** 1.0  
**Status:** ✅ Active

