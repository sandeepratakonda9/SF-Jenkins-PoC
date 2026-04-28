#!/bin/bash
set -e
sf plugins
# Write scanner output to terminal
#echo -e "──────────────────────────────────────────────────────────────────────────\n\nScan code of Common ...\n\n──────────────────────────────────────────────────────────────────────────"
#sf scanner run --format table --target common_frameworks/com_batch-control/main/default/classes --category '!Documentation' --verbose --severity-threshold 2
#sf scanner run --format table --target common_frameworks/com_rest-api-framework/main/default/classes --category '!Documentation' --verbose --severity-threshold 2
#echo -e "──────────────────────────────────────────────────────────────────────────\n\nScan code of Retention & IVR ...\n\n──────────────────────────────────────────────────────────────────────────"
#sf scanner run --format table --target fs_bl/main/default/classes --category '!Documentation' --verbose --severity-threshold 2
#echo -e "──────────────────────────────────────────────────────────────────────────\n\nScan code of Credit ...\n\n──────────────────────────────────────────────────────────────────────────"
#sf scanner run --format table --target fs_credit/main/default/classes --category '!Documentation' --verbose --severity-threshold 2
#sf scanner run --format table --target fs_credit/main/default/lwc --category '!Documentation' --verbose --severity-threshold 2
#echo -e "──────────────────────────────────────────────────────────────────────────\n\nScan code of Client Services ...\n\n──────────────────────────────────────────────────────────────────────────"
#sf scanner run --format table --target fs_clientServices/main/default/classes --category '!Documentation' --verbose --severity-threshold 2
#sf scanner run --format table --target fs_clientServices/main/default/lwc --category '!Documentation' --verbose --severity-threshold 2
#echo -e "──────────────────────────────────────────────────────────────────────────\n\nScan code of additional components ...\n\n──────────────────────────────────────────────────────────────────────────"
#sf scanner run --format table --target fs_ohCop/main/default/classes --category '!Documentation' --verbose --severity-threshold 2
#sf scanner run --format table --target fs_ohCop/main/default/lwc --category '!Documentation' --verbose --severity-threshold 2

echo -e "──────────────────────────────────────────────────────────────────────────\n\nScan code of whole repository ...\n\n──────────────────────────────────────────────────────────────────────────"
sf code-analyzer run --view table --target ./ --rule-selector pmd