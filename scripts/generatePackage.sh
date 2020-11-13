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
    echo "Build the retrieve Package.xml"
    echo -ne "\rIn Progress... ⏳ "
    output="$(${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PapiVersion=${API_VERSION} -PpackagePath=temp/RetrievePackage -PmetadataTypesPath=temp/MetadataTypes generateRetrievePackageXML)"
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError generateRetrievePackageXML"
        echo -e "\e[31m${output}"
        exit 1
    else
        echo -e "\rDone ✅           "
        echo -e "$(cat temp/RetrievePackage/package.xml)"
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
    echo -e "Please wait this step may take few minutes..."
    sfdx force:mdapi:retrieve -u ${SOURCE_ORG} -k temp/RetrievePackage/package.xml -r temp/TempPackage -w -1
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError retrievePackage : retrieving the package"
        echo -e "\e[31m${output}"
        exit 1
    fi

    echo -e "\rUnzipping the package"
    echo -ne "\rIn Progress... ⏳ "
    output="$(unzip temp/TempPackage/unpackaged.zip -d temp/RetrievePackage 2>&1)"
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError retrievePackage : unzipping the package"
        echo -e "\e[31m${output}"
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
    cp -r temp/RetrievePackage/unpackaged/profiles temp/DeployPackage/profiles

    echo
    echo -e "\rBuild Target Package.xml"
    output="$(${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PapiVersion=${API_VERSION} -PpackagePath=temp/DeployPackage generateDeployPackageXML)"
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError generateDeployPackage"
        echo -e "\e[31m${output}"
        exit 1
    else
        echo -e "$(cat temp/DeployPackage/package.xml)"
    fi

}

#######################################
# retrievePackage : retrieve the profiles package
#######################################
function cleanProfiles(){

    echo
    echo -ne "\rCleaning CustomFields 🧹 "
    output="$(${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=CustomField -PmetadataTypeFolder=temp/MetadataTypes/CustomField -PprofileFolder=temp/DeployPackage/profiles cleanProfiles 2>&1)"
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError cleanProfiles : CustomFields"
        echo -e "\e[31m${output}"
        exit 1
    fi
    echo -e "\rCleaning CustomFields ✅ "

    echo -ne "\rCleaning RecordTypes 🧹 "
    output="$(${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=RecordType -PmetadataTypeFolder=temp/MetadataTypes/RecordType -PprofileFolder=temp/DeployPackage/profiles cleanProfiles 2>&1)"
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError cleanProfiles : RecordTypes"
        echo -e "\e[31m${output}"
        exit 1
    fi
    echo -e "\rCleaning RecordTypes ✅ "

    echo -ne "\rCleaning UserPermissions 🧹 "
    output="$(${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=UserPermission -PmetadataTypeFolder=temp/MetadataTypes/UserPermission -PprofileFolder=temp/DeployPackage/profiles cleanProfiles 2>&1)"
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError cleanProfiles : UserPermissions"
        echo -e "\e[31m${output}"
        exit 1
    fi
    echo -e "\rCleaning UserPermissions ✅ "

}


# =================================== main ==================================
buildPackage
echo -e "\r\e[32mPackage successfully built 🏗️"