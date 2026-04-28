# Team-Based Test Selection for PR Validation

## Overview

This enhancement optimizes PR validation by running only relevant test classes based on the team and the files changed in the PR, instead of running all ~1000+ test methods on every PR. The system supports three teams with isolated test execution:

- **OneOps Team**: 104 test classes across 6 folders
- **OneHouse Team**: 90 test classes across 2 folders  
- **Athlon Team**: 5 test classes in 1 folder (isolated execution)

## How It Works

### Team Identification

The system identifies which team's code is being changed using two methods:

1. **Branch Naming Pattern** (existing logic):
   - OneHouse: branches starting with `oh/COP*`, `oh/CHA*`, or `oh/*`
   - OneOps: all other branches (default)

2. **Changed Files Analysis** (new logic):
   - OneOps folders: `fs_credit`, `fs_retention`, `fs_clientServices`, `fs_ivr`, `fs_bl`, `fs_dealerMgmt`
   - OneHouse folders: `fs_ohCop`, `fs_ohCmp`
   - Athlon folders: `fs_athlon`

### Test Selection Logic

- **OneOps Team Changes**: Runs 104 test classes from OneOps folders
- **OneHouse Team Changes**: Runs 90 test classes from OneHouse folders
- **Athlon Team Changes**: Runs 5 test classes from Athlon folder only
- **Mixed Changes**: Runs all relevant test classes based on which teams have changes
- **No Team-Specific Changes**: Falls back to `RunLocalTests` (existing behavior)
- **No Relevant Changes**: Uses `NoTestRun` (existing behavior)

## Files Modified

### 1. `.deployment/scripts/selectTestsByTeam.sh`
**New script** that:
- Analyzes changed files and branch names
- Determines the appropriate team
- Extracts test classes from relevant folders
- Sets environment variables for the workflow

### 2. `.github/workflows/PR_Validation.yml`
**Updated** to:
- Call the new test selection script
- Display test selection results for debugging
- Use the selected test classes for validation

### 3. `.deployment/scripts/validateSourceFormat.sh`
**Updated** to:
- Support `RunSpecifiedTests` with the `--tests` parameter
- Use the `TEST_CLASSES` environment variable when available
- Maintain backward compatibility with existing test levels

## Environment Variables

The test selection script sets these environment variables:

- `SIT_TEST_RUN`: Test level (`RunSpecifiedTests`, `RunLocalTests`, or `NoTestRun`)
- `TEST_CLASSES`: Space-separated list of test class names (when using `RunSpecifiedTests`)

## Test Class Distribution

### OneOps Team (104 test classes)
- **fs_credit**: 53 test classes
- **fs_retention**: 22 test classes
- **fs_clientServices**: 14 test classes
- **fs_bl**: 13 test classes
- **fs_dealerMgmt**: 2 test classes
- **fs_ivr**: 0 test classes

### OneHouse Team (90 test classes)
- **fs_ohCop**: 67 test classes
- **fs_ohCmp**: 23 test classes

### Athlon Team (5 test classes)
- **fs_athlon**: 5 test classes

## Benefits

1. **Faster PR Validation**: Reduces test execution time significantly:
   - OneOps: ~104 tests instead of 1000+
   - OneHouse: ~90 tests instead of 1000+
   - Athlon: Only 5 tests instead of 1000+
2. **Team Isolation**: Each team's PRs only run their own tests, reducing noise and cross-team interference
3. **Flexible Architecture**: Supports multiple teams (OneOps, OneHouse, Athlon) with isolated test execution
4. **Intelligent Detection**: Uses both branch patterns and file changes for accurate team detection
5. **Backward Compatibility**: Falls back to existing behavior when team detection fails
6. **Clear Logging**: Provides detailed information about test selection in workflow logs

## Usage Examples

### OneOps PR with fs_credit changes
- **Input**: Files changed in `fs_credit/`, `fs_bl/`, or `fs_dealerMgmt/`
- **Output**: Runs 104 test classes from OneOps folders
- **Command**: `sf project deploy start ... --tests FS_ApplicationFlow_TEST FS_CreditSummaryFlow_TEST FS_CustomMetadataQuery_Test FS_WholesaleProductATFlow_Test ...`

### OneHouse PR with fs_ohCop changes
- **Input**: Branch `oh/COP123` with files in `fs_ohCop/`
- **Output**: Runs 90 test classes from OneHouse folders
- **Command**: `sf project deploy start ... --tests EU_TestDataFactory EU_InitiateC7_Test ...`

### Athlon PR with fs_athlon changes
- **Input**: Files changed in `fs_athlon/`
- **Output**: Runs only 5 test classes from fs_athlon folder
- **Command**: `sf project deploy start ... --tests AT_CaseFlowTEST AT_TaskFlowTest AT_AccountContactRelationFlowTest ...`

### Mixed Changes (Multiple Teams)
- **Input**: Files in `fs_credit/`, `fs_ohCop/`, and `fs_athlon/`
- **Output**: Runs all 199 relevant test classes from all teams
- **Command**: `sf project deploy start ... --tests FS_ApplicationFlow_TEST EU_TestDataFactory AT_CaseFlowTEST ...`

## Debugging

The workflow includes a "Display test selection results" step that shows:
- Selected test run type
- Number of test classes selected
- Sample of selected test class names

Check the GitHub Actions logs for this information when debugging test selection issues.

## Future Enhancements

1. **Performance Monitoring**: Track test execution time improvements across all teams
2. **Test Coverage**: Ensure adequate coverage with reduced test scope per team
3. **Dynamic Discovery**: Automatically discover new test classes as they're added
4. **Cross-Dependencies**: Handle cases where team changes might affect other teams' functionality
5. **Additional Teams**: Easily add new teams by updating the folder arrays and logic
6. **Smart Dependencies**: Analyze code dependencies to determine if cross-team testing is needed
