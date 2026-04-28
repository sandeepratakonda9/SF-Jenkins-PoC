#!/bin/bash
ALIAS="$1"
TESTLEVEL="$2"
set -e

#script parameters
testClasses=""
SPECIFIED="RunSpecifiedTests"
LOCAL="RunLocalTests"

#iterate over all files in apex classes
for file in com_batch-control/main/default/classes/COM_*TEST.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass,"
    fi 
done
for file in com_rest-api-framework/main/default/classes/COM_*TEST.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass,"
    fi 
done
for file in fs_clientServices/main/default/classes/FS_*TEST.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass,"
    fi 
done
for file in fs_ohCop/main/default/classes/EU_*TEST.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass,"
    fi 
done
for file in fs_ohCop/main/default/classes/EU_*Test.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass,"
    fi 
done
for file in fs_credit/main/default/classes/FS_*TEST.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass,"
    fi 
done
for file in fs_bl/main/default/classes/FS*TEST.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass,"
    fi 
done
for file in fs_bl/main/default/classes/FS*Test.cls; do 
    if [ -f "$file" ]; then 
		newTestClass=$(basename $file)
		testClasses="$testClasses$newTestClass"
    fi 
done

#remove file extension
testClasses=${testClasses//".cls"/""}

echo "$testClasses"

# Run apex tests in target org
if [ "$TESTLEVEL" = "$SPECIFIED" ];then
    sf apex run test --target-org $ALIAS --wait 120 --result-format human --code-coverage --test-level $TESTLEVEL --detailed-coverage --class-names "$testClasses" 
fi
if [ "$TESTLEVEL" = "$LOCAL" ];then
    sf apex run test --target-org $ALIAS --wait 120 --result-format human --code-coverage --test-level $TESTLEVEL --detailed-coverage
fi