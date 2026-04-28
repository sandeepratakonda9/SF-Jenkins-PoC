#!/bin/bash
POSTORG_VALIDATION="${1:-deployment}"

set -euo pipefail

echo "Running generic pre-processing for STAGE ($POSTORG_VALIDATION mode)"
echo "No client-specific metadata pruning is applied in this repository."