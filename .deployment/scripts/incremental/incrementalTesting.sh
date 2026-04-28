#!/bin/bash
VERSIONNAME="MBM-PI3-S02-Testing"
VERSIONDESCRIPTION="Sprint 02 - Incremental testing"
INSTALLATIONKEY="MBCRM202X"

#json_string=$(.deployment/scripts/incremental/packageIdentificationNew.sh ONEOPS-272 origin/stage)

#echo "$json_string" | jq

#json_string2=$(.deployment/scripts/incremental/packageCreationIncremental.sh "$json_string" MBM_PROD $VERSIONNAME $VERSIONDESCRIPTION $INSTALLATIONKEY)
#echo "$json_string2" | jq
#.deployment/scripts/incremental/packageInstallationIncremental.sh "$json_string2" MBM_SO_ONEOPS-1434-Test2 $INSTALLATIONKEY

.deployment/scripts/orchastration_mb/packagingIncremental.sh ONEOPS-272 origin/stage MBM_PROD MBM_SO_ONEOPS-1434-Test2 $VERSIONNAME $VERSIONDESCRIPTION $INSTALLATIONKEY
