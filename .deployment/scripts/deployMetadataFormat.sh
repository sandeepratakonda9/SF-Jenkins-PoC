#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"
CHECKONLY="$3"

if [ $CHECKONLY == 'CheckOnly' ]; then
CHECKONLY="--dry-run"
else
CHECKONLY=""
fi

set -e
mkdir ./mdapi_output_dir

# Validate or Deploy to your target org in Metadata API format

sf project convert source --root-dir ./ --output-dir ./mdapi_output_dir
sf project deploy start --metadata-dir ./mdapi_output_dir --target-org $ALIAS --test-level $TESTLEVEL --wait 120 --verbose $CHECKONLY
                    