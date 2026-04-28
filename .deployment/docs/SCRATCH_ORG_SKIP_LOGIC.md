# Scratch Org Validation Skip Logic

## Overview
The scratch org validation in the PR workflow now intelligently skips validation for low-risk changes, saving approximately **2+ hours** per PR when conditions are met.

## Implementation
The logic is implemented in a dedicated script: `.deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh`

This script leverages the delta generation from `sfdx-git-delta` plugin to:
- Check `destructiveChanges.xml` for deletions
- Analyze the delta directory structure for affected folders
- Detect settings folder changes

**Benefits of this approach:**
- ✅ Accurate deletion detection via `destructiveChanges.xml`
- ✅ Efficient folder analysis using already-generated delta
- ✅ Clean workflow file (logic extracted to script)
- ✅ Reusable script for other workflows

---

## How It Works (Delta-Based Analysis)

### Delta Generation
The workflow uses `sf sgd source delta` (sfdx-git-delta plugin) to generate a delta package:

```bash
sf sgd source delta --from "origin/develop" --to "HEAD" \
  --output-dir ./temp-delta-deployment \
  --generate-delta \
  --ignore-file .sgdeltaignore
```

This creates a `temp-delta-deployment` directory with:
- Changed/added metadata files organized by folder
- `destructiveChanges/destructiveChanges.xml` - List of deleted items
- `package.xml` - Package manifest

### Analysis
The assessment script then analyzes this delta to determine:
1. Are there deletions? → Check `destructiveChanges.xml`
2. Is settings folder affected? → Check `temp-delta-deployment/fs_dm/main/default/settings`
3. How many folders changed? → Count directories in delta

This approach is **more accurate** than using GitHub API because it:
- Respects `.sgdeltaignore` patterns
- Captures actual Salesforce metadata changes
- Identifies deletions in the Salesforce package format

---

## When Scratch Org Validation RUNS

The scratch org validation will **ALWAYS RUN** if **ANY** of these conditions are met:

### 1. 🔴 Deletions Detected
**Any file is deleted in the PR**

```bash
# Examples that trigger validation:
- force-app/main/default/classes/MyClass.cls (removed)
- fs_dm/main/default/objects/CustomObject__c/CustomObject__c.object-meta.xml (removed)
```

**Why?** Deletions can break dependencies and require full validation to ensure nothing breaks.

---

### 2. 🔴 Settings Folder Changed
**Any file in `fs_dm/main/default/settings/` is modified**

```bash
# Examples that trigger validation:
- fs_dm/main/default/settings/Address.settings-meta.xml
- fs_dm/main/default/settings/Communities.settings-meta.xml
```

**Why?** Settings changes can have org-wide impacts and need full validation.

---

### 3. 🔴 Multiple Folders Changed
**Changes affect MORE THAN ONE of these folders:**

```
common_frameworks
core_dm
fs_dm
fs_bl
fs_retention
fs_clientServices
fs_credit
fs_industryCloud
fs_ivr
fs_post_access-mgmt
fs_post_config
fs_post_ui
fs_dealerMgmt
fs_ohCop
fs_ohCmp
fs_athlon
```

**Example that triggers validation:**
```bash
# Changes in 2 different folders:
- fs_dm/main/default/classes/MyClass.cls
- fs_bl/main/default/classes/BusinessLogic.cls
```

**Why?** Multi-folder changes indicate complex changes that need full validation.

---

## When Scratch Org Validation SKIPS

Validation will be **SKIPPED** when **ALL** of these conditions are met:

- ✅ No deletions
- ✅ Settings folder unchanged (`fs_dm/main/default/settings/`)
- ✅ Only 0-1 relevant folders affected

### Examples of PRs That Skip

#### Example 1: Single folder change (OneOps)
```bash
# Only fs_dm changes:
- fs_dm/main/default/classes/PaymentController.cls
- fs_dm/main/default/triggers/PaymentTrigger.trigger
```
**Result:** ⏭️ SKIPPED - Single folder (fs_dm)

---

#### Example 2: Documentation only
```bash
# Only docs/CI changes:
- .deployment/scripts/myScript.sh
- .github/workflows/PR_Validation.yml
- README.md
```
**Result:** ⏭️ SKIPPED - No relevant folders changed

---

#### Example 3: Single Athlon change
```bash
# Only Athlon folder:
- fs_athlon/main/default/classes/AthlonClass.cls
```
**Result:** ⏭️ SKIPPED - Single folder (fs_athlon)

---

## Workflow Output

### When Validation Runs
```
=== Assessing if Scratch Org Validation is Required ===
✓ Deletions detected - scratch org validation REQUIRED
force-app/main/default/classes/OldClass.cls

=== Decision ===
SKIP_SCRATCH_ORG: false
Reason: Deletions detected
```

---

### When Validation Skips
```
=== Assessing if Scratch Org Validation is Required ===
  No deletions found
  No settings folder changes
  Relevant folders affected: 1 (fs_dm)
⚠️  No critical changes detected:
    - No deletions
    - Settings folder unchanged
    - Only 1 folder(s) changed
  → Scratch org validation will be SKIPPED to save time

=== Decision ===
SKIP_SCRATCH_ORG: true
Reason: Low-risk changes only (fs_dm)

🎉 Scratch Org validation is being skipped!
Reason: Low-risk changes only (fs_dm)

This saves approximately 2+ hours of validation time.
The changes in this PR are considered low-risk and do not require full scratch org validation.
```

---

## Decision Flow

```
PR Files Changed
      │
      ▼
Are there deletions? ─────YES───→ RUN VALIDATION 🔴
      │
      NO
      │
      ▼
Settings folder changed? ─YES───→ RUN VALIDATION 🔴
      │
      NO
      │
      ▼
Count relevant folders
      │
      ▼
More than 1 folder? ──────YES───→ RUN VALIDATION 🔴
      │
      NO
      │
      ▼
SKIP VALIDATION ✅
(Save 2+ hours)
```

---

## Testing Examples

### Test Case 1: Should SKIP
**PR Changes:**
```
fs_dm/main/default/classes/PaymentController.cls
fs_dm/main/default/classes/PaymentController.cls-meta.xml
```

**Expected:** ✅ SKIP (single folder, no deletions, no settings)

---

### Test Case 2: Should RUN (Deletion)
**PR Changes:**
```
fs_dm/main/default/classes/OldClass.cls (DELETED)
```

**Expected:** 🔴 RUN (deletion detected)

---

### Test Case 3: Should RUN (Settings)
**PR Changes:**
```
fs_dm/main/default/settings/Address.settings-meta.xml
```

**Expected:** 🔴 RUN (settings folder changed)

---

### Test Case 4: Should RUN (Multiple Folders)
**PR Changes:**
```
fs_dm/main/default/classes/Class1.cls
fs_bl/main/default/classes/Class2.cls
```

**Expected:** 🔴 RUN (2 folders affected)

---

### Test Case 5: Should SKIP (Documentation)
**PR Changes:**
```
.deployment/scripts/myScript.sh
README.md
.github/workflows/test.yml
```

**Expected:** ✅ SKIP (no relevant folders)

---

### Test Case 6: Should SKIP (Single Athlon)
**PR Changes:**
```
fs_athlon/main/default/classes/AthlonController.cls
fs_athlon/main/default/objects/Athlon__c/Athlon__c.object-meta.xml
```

**Expected:** ✅ SKIP (single folder: fs_athlon)

---

## Monitoring & Metrics

### View Skip Decisions in GitHub Actions

1. Go to Actions tab
2. Select your PR workflow run
3. Open "Scratch Org dry-run" job
4. Look for step: "Assess if scratch org validation is required"
5. Check the output for the decision

### Track Savings

You can track time savings by monitoring:
- How often validation is skipped
- Average PR completion time (with vs without scratch org)

**Expected Savings:**
- Skipped PRs: ~2+ hours saved
- Typical single-folder PR: 50-70% of PRs could skip
- **Overall impact: 30-40% reduction in total validation time**

---

## Configuration

### Modify Relevant Folders

If you need to add/remove folders from the check, edit the assessment script:

```bash
# In: .deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh
# Around line 25

RELEVANT_DIRS=(
    "common_frameworks"
    "core_dm"
    "fs_dm"
    # Add or remove folders here
)
```

### Disable Skip Logic Temporarily

To force all PRs to run scratch org validation:

**Option 1: Modify the script**
```bash
# In: .deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh
# Add at the top of the script after "set -e":
echo "SKIP_SCRATCH_ORG=false" >> $GITHUB_ENV
echo "SKIP_REASON=Skip logic disabled" >> $GITHUB_ENV
exit 0
```

**Option 2: Comment out the assessment step in workflow**
```yaml
# In: .github/workflows/PR_Validation.yml
# Comment out the assessment step:
# - name: Assess if scratch org validation is required
#   run: |
#     chmod +x .deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh
#     .deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh ./temp-delta-deployment
```

### Running the Script Manually

You can test the assessment logic locally:

```bash
# Generate delta
sf sgd source delta --from "origin/develop" --to "HEAD" \
  --output-dir ./temp-delta-deployment \
  --generate-delta \
  --ignore-file .sgdeltaignore

# Run assessment
.deployment/scripts/scratchOrgs/assessScratchOrgValidationNeed.sh ./temp-delta-deployment

# Check result
echo $?  # Should be 0
```

---

## Benefits

✅ **Time Savings:** 2+ hours per low-risk PR  
✅ **Resource Savings:** Less runner usage  
✅ **Faster Feedback:** Developers get PR status faster  
✅ **Safe:** Only skips truly low-risk changes  
✅ **SIT Still Runs:** SIT validation always runs for code changes  

---

## Important Notes

1. **SIT validation still runs** - Only scratch org is conditionally skipped
2. **Scratch org ALWAYS runs for high-risk changes** - Safety first
3. **Settings folder is always validated** - Known high-impact area
4. **Deletions are never skipped** - Too risky
5. **Multi-folder changes always validate** - Complexity requires testing

---

## Rollback

If you need to disable this feature:

```yaml
# In .github/workflows/PR_Validation.yml
# Remove or comment out the "if: env.SKIP_SCRATCH_ORG != 'true'" conditions
# from all steps in the validateAgainstScratchOrg job
```

---

**Implemented:** Dec 4, 2025  
**Version:** 1.0  
**Status:** ✅ Active

