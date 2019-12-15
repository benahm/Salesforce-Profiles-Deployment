#!/bin/sh
#
# author : benahm
# description : clean profiles package 

. ./config/config.properties

cleanItems="$(cat config/additionalClean.list | tr -d '\r' | tr '\n' ' ')"

if [ ! -z "$cleanItems" ]; then
    echo "=== Additional cleaning ==="
    for cleanItem in ${cleanItems}; do
        metadaType=${cleanItem%:*}
        metadataName=${cleanItem#*:}
        additionalCleanFolder=temp/MetadataTypes/__Additional
        echo -ne "Cleaning ${metadaType} ${metadataName} 🧹 "
        rm -rf ${additionalCleanFolder} &>/dev/null
        mkdir -p ${additionalCleanFolder} &>/dev/null
        echo ${metadataName} > ${additionalCleanFolder}/SourceSubTarget.list
        ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=${metadaType} -PmetadataTypeFolder=${additionalCleanFolder} -PprofileFolder=temp/DeployPackage/profiles cleanProfiles &>/dev/null
        echo -e "\rCleaning ${metadaType} ${metadataName} ✅ "
    done
else 
    echo -e "Additional cleaning should be configured in the config/config.properties file"
    echo -e "Example : CustomField:Campaign.CampaignImageId"
fi