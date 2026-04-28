#!/bin/bash
ALIAS="$1"
set -e
# Mark target org as deleted
sf org delete scratch --target-org $ALIAS --no-prompt