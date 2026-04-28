#!/bin/bash
set -euo pipefail

# Scratch-org delta validation should trigger if package directories changed.
.deployment/scripts/orchastration_mb/checkChangedDirectories.sh
