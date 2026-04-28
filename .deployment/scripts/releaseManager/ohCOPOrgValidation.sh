#!/bin/bash
ALIAS="$1"
set -e

#rm -rf fs_dm/main/default/settings/Address.settings-meta.xml #removal due to manual steps to get this deployed
rm -rf fs_dealerMgmt/customer-package/application/mod2/main/default/applications/Wholesale_App.app-meta.xml
rm -rf fs_post_org-dependent
