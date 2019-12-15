#!/bin/sh
#
# author : benahm
# description : deploy the profiles package to the target

. ./config/config.properties

IS_CHECK_ONLY=$1

checkOnlyArgument=""

# deploy with the check only argument is set
if [ "$IS_CHECK_ONLY" == "Y" ]; then
    echo "Deploying with check only = true"
    checkOnlyArgument="-c"
fi

echo "Deploying profiles to target"
sfdx force:mdapi:deploy ${checkOnlyArgument} -u ${TARGET_ORG} -d temp/DeployPackage -w -1