#!/bin/sh
#
# author : benahm
# description : generate profiles package

. ./config/config.properties


#######################################
# listProfileMetadataTypes : list metadata related to profiles
# GLOBAL :
#   SOURCE_ORG : alias of the source org 
#   TARGET_ORG : alias of the targer org
#   API_VERSION : api version
#######################################
function buildPackage(){

    # check SOURCE_ORG param
    if [ -z "$SOURCE_ORG" ]; then
        echo -e "\e[31mSOURCE_ORG should be configured in the config/config.properties file"
        exit 1;
    fi

    # check TARGET_ORG param
    if [ -z "$TARGET_ORG" ]; then
        echo -e "\e[31mTARGET_ORG should be configured in the config/config.properties file"
        exit 1;
    fi

    # check API_VERSION param
    if [ -z "$API_VERSION" ]; then
        echo -e "\e[31mAPI_VERSION should be configured in the config/config.properties file"
        exit 1;
    fi

    generateRetrievePackageXML
    retrievePackage
    generateDeployPackage
    cleanProfiles
}


#######################################
# generateRetrievePackageXML : generate the retrieve package xml
#######################################
function generateRetrievePackageXML(){

    echo
    echo "Build Retrieve Package.xml"
    ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PapiVersion=${API_VERSION} -PpackagePath=temp/RetrievePackage -PmetadataTypesPath=temp/MetadataTypes generateRetrievePackageXML 
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError generateRetrievePackageXML"
        exit 1
    fi
}

#######################################
# retrievePackage : retrieve the profiles package
#######################################
function retrievePackage(){

    rm -r temp/RetrievePackage/*/ &>/dev/null
    rm -rf temp/TempPackage &>/dev/null
    mkdir -p temp/TempPackage &>/dev/null

    echo
    echo -e "\rRetrieve profiles from ${SOURCE_ORG}"
    echo -ne "\rIn Progress... ⏳ "
    sfdx force:source:retrieve -u ${SOURCE_ORG} -x temp/RetrievePackage/package.xml &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError retrievePackage : retrieving the package"
        exit 1
    fi
    echo -e "\rDone ✅           "

    echo -e "\rConverting profiles package to metadata format"
    echo -ne "\rIn Progress... ⏳ "
    sfdx force:source:convert -p temp/TempPackage -d temp/RetrievePackage &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError retrievePackage : converting the package"
        exit 1
    fi
    echo -e "\rDone ✅           "

    rm -rf temp/TempPackage/* &>/dev/null

}

#######################################
# retrievePackage : retrieve the profiles package
#######################################
function generateDeployPackage(){

    rm -rf temp/DeployPackage/* &>/dev/null
    mkdir -p temp/DeployPackage/ &>/dev/null

    echo
    echo -e "\rCopying profiles to the deploy package"
    cp -r temp/RetrievePackage/profiles temp/DeployPackage/profiles

    echo
    echo -e "\rBuild Target Package.xml"
    ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PapiVersion=${API_VERSION} -PpackagePath=temp/DeployPackage generateDeployPackageXML 
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError generateDeployPackage"
        exit 1
    fi
}

#######################################
# retrievePackage : retrieve the profiles package
#######################################
function cleanProfiles(){

    echo
    echo -ne "\rCleaning CustomFields 🧹 "
    ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=CustomField -PmetadataTypeFolder=temp/MetadataTypes/CustomField -PprofileFolder=temp/DeployPackage/profiles cleanProfiles &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError cleanProfiles : CustomFields"
        exit 1
    fi
    echo -e "\rCleaning CustomFields ✅ "

    echo -ne "\rCleaning RecordTypes 🧹 "
    ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=RecordType -PmetadataTypeFolder=temp/MetadataTypes/RecordType -PprofileFolder=temp/DeployPackage/profiles cleanProfiles &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError cleanProfiles : RecordTypes"
        exit 1
    fi
    echo -e "\rCleaning RecordTypes ✅ "

    echo -ne "\rCleaning UserPermissions 🧹 "
    ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=UserPermission -PmetadataTypeFolder=temp/MetadataTypes/UserPermission -PprofileFolder=temp/DeployPackage/profiles cleanProfiles &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError cleanProfiles : UserPermissions"
        exit 1
    fi
    echo -e "\rCleaning UserPermissions ✅ "

}


# =================================== main ==================================
buildPackage
echo -e "\r\e[32mPackage successfully built 🏗️"