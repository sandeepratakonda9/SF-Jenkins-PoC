#!/bin/bash
ALIAS_DEVHUB="$1"

set -e
chmod +x .deployment/scripts/*.sh && chmod +x .deployment/scripts/orchastration_mb/*.sh && chmod +x .deployment/scripts/releaseManager/*.sh

rm -r fs_post_access-mgmt/profiles

.deployment/scripts/packageCreation.sh MB-CORE-DM $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-COM-Batch-Control $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-FS-DM $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-FS-IVR $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-FS-BL $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-FS-Credit-DM $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-FS-Credit-BL $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-FS-ClientServices-DM $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
.deployment/scripts/packageCreation.sh MB-FS-ClientServices-BL $ALIAS_DEVHUB "MBCRM202X" calculateCodeCoverage formatOutputAsJSON 
