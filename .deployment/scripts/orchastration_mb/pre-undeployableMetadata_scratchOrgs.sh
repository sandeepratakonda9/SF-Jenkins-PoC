#!/bin/bash
OMNISTUDIO_SUPPORT="${1:-SO_SUPPORTS_OMNI}"
SCRATCH_SCOPE_FLAG="${2:-TRUE}"

set -euo pipefail

echo "Running generic scratch-org pre-processing"
echo "Omni support flag: $OMNISTUDIO_SUPPORT"
echo "Scope flag: $SCRATCH_SCOPE_FLAG"
echo "No project-specific metadata pruning is applied."
