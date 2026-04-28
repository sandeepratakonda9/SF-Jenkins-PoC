#!/bin/bash
ALIAS="$1"
TARGETORGTYPE="$2"
DEPLOYONEOPS="$3"
DEPLOYONEHOUSE="$4"
DEPLOYCOLLECTIONS="$5"

set -e

# Set TESTLEVEL based on the value of TARGETORGTYPE
if [ "$TARGETORGTYPE" == "SCRATCHORGPLAIN" ] || [ "$TARGETORGTYPE" == "SCRATCHORGFULL" ]; then
  TESTLEVEL="NoTestRun"
  TESTLEVEL_NO_CODE="NoTestRun"
elif [ "$TARGETORGTYPE" == "DEVOPSSANDBOX" ]; then
  TESTLEVEL="NoTestRun"
  TESTLEVEL_NO_CODE="NoTestRun"
elif [ "$TARGETORGTYPE" == "RELEASETESTORG" ]; then
  TESTLEVEL="RunLocalTests"
  TESTLEVEL_NO_CODE="NoTestRun"
elif [ "$TARGETORGTYPE" == "RELEASEORG" ]; then
  TESTLEVEL="RUNDEFAULT"
  TESTLEVEL_NO_CODE="RUNDEFAULT"
else
  echo "Invalid TARGETORGTYPE."
  exit 1
fi

# Output the value of TESTLEVEL
echo "TESTLEVEL is set to $TESTLEVEL"


if [ $DEPLOYONEOPS == "TRUE" ]; then
    echo -e "──────────────────────────────────────────────────────────────────────────\n\nStart deploment of all folders ...\n\n──────────────────────────────────────────────────────────────────────────"
  if [ $TARGETORGTYPE == "SCRATCHORGFULL" ]; then
      echo -e "──────────────────────────────────────────────────────────────────────────\n\nSkipping deployment of rather static FS folders to prepared Scratch Org ...\n\n──────────────────────────────────────────────────────────────────────────"
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_dm/main/default/settings
  else
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath core_dm
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath common_frameworks
      echo -e "──────────────────────────────────────────────────────────────────────────\n\nStarting deployment of fs_ directories ...\n\n──────────────────────────────────────────────────────────────────────────"
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_dm
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_ivr
      sleep 5m
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath fs_bl
      sleep 5m
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_industryCloud/retention
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath fs_retention
      sleep 1m
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_industryCloud/clientServices
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath fs_clientServices
      sleep 1m
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath fs_dealerMgmt
      sleep 1m
  fi

  # FS Credit dir
  if [ "$TARGETORGTYPE" == "SCRATCHORGPLAIN" ] || [ "$TARGETORGTYPE" == "SCRATCHORGFULL" ]; then
      echo -e "──────────────────────────────────────────────────────────────────────────\n\nStarting Scratch org deployments of Decision Matrices & Omni dependencies ...\n\n──────────────────────────────────────────────────────────────────────────"
      .deployment/scripts/scratchOrgs/scratchOrgOOPreDeployments.sh $ALIAS
  fi

  .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_industryCloud/credit
  .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath fs_credit

  # Athlon team dir
  .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath fs_athlon

else
    echo -e "──────────────────────────────────────────────────────────────────────────\n\nSkipping deployment of fs_ directories, continuing with OneHouse folders ...\n\n──────────────────────────────────────────────────────────────────────────"
fi

# FS OneHouse dirs
if [ $DEPLOYONEHOUSE == "TRUE" ]; then
echo -e "──────────────────────────────────────────────────────────────────────────\n\nDeploying OneHouse Components ...\n\n──────────────────────────────────────────────────────────────────────────"    
    if [ "$TARGETORGTYPE" == "SCRATCHORGPLAIN" ] || [ "$TARGETORGTYPE" == "SCRATCHORGFULL" ]; then
        .deployment/scripts/scratchOrgs/scratchOrgOHPreDeployments.sh $ALIAS
    fi
    # FS OneHouse COP dirs
    .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_industryCloud/ohCop
    .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath ./fs_ohCop
    if [ "$TARGETORGTYPE" == "SCRATCHORGPLAIN" ] || [ "$TARGETORGTYPE" == "SCRATCHORGFULL" ] || [ "$DEPLOYCOLLECTIONS" = "FALSE" ] ; then
      echo -e "──────────────────────────────────────────────────────────────────────────\n\nSkipped deployment of fs_ohCmp/fs_collections folder, because of pilot features not supporting it yet ... deploying only groups to resolve dependencies of Sharing Rules\n\n──────────────────────────────────────────────────────────────────────────"
    else
      # FS OneHouse CMP Collections dirs
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_industryCloud/ohCmp
      .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath fs_ohCmp/fs_collections
    fi
else
    echo -e "──────────────────────────────────────────────────────────────────────────\n\nSkipped deployment of fs_ohCop folder, because DEPLOYONEHOUSE variable is set to FALSE ...\n\n──────────────────────────────────────────────────────────────────────────"
    if [ "$TARGETORGTYPE" == "SCRATCHORGPLAIN" ] || [ "$TARGETORGTYPE" == "SCRATCHORGFULL" ]; then
        echo -e "──────────────────────────────────────────────────────────────────────────\n\nDeploying OH Account object & Groups to Scratch org to resolve Sharing Rule dependencies ...\n\n──────────────────────────────────────────────────────────────────────────"
        .deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL sourcepath "fs_ohCop/main/default/groups fs_ohCop/main/default/customPermissions fs_ohCop/main/default/objects/EU_IndustryDetails__c fs_ohCop/main/default/objects/Account fs_ohCop/main/default/objects/PartyFinancialAsset fs_ohCop/main/default/globalValueSets/EU_ContractChangeReason.globalValueSet-meta.xml fs_ohCop/main/default/globalValueSets/EU_FinancialProductType.globalValueSet-meta.xml fs_ohCop/main/default/objects/FinancialAccount"
    fi
fi

# FS post-deployment dirs
sleep 3m
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath ./fs_post_config
sleep 3m
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath ./fs_post_ui
sleep 3m
.deployment/scripts/deploySourceFormat.sh $ALIAS $TESTLEVEL_NO_CODE sourcepath ./fs_post_access-mgmt

echo -e "──────────────────────────────────────────────────────────────────────────\n\nDEPLOYMENT COMPLETED!\n\n──────────────────────────────────────────────────────────────────────────"
