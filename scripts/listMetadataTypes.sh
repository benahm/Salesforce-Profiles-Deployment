#!/bin/sh
#
# author : benahm
# description : list metadatas from Source & Target

. ./config/config.properties

# ================================= functions =================================
#######################################
# listProfileMetadataTypes : list metadata related to profiles
# GLOBAL :
#   SOURCE_ORG : alias of the source org 
#   TARGET_ORG : alias of the targer org
#######################################
function listProfileMetadataTypes(){

    if [ -z "$SOURCE_ORG" ]; then
        echo -e "\e[31mSOURCE_ORG should be configured in the config/config.properties file"
        exit 1;
    fi

    if [ -z "$TARGET_ORG" ]; then
        echo -e "\e[31mTARGET_ORG should be configured in the config/config.properties file"
        exit 1;
    fi

    # Custom application
    echo "======================= CustomApplication ======================="
    rm -rf temp/MetadataTypes/CustomApplication
    listMetadataType ${SOURCE_ORG} Source CustomApplication temp/MetadataTypes/CustomApplication
    listMetadataType ${TARGET_ORG} Target CustomApplication temp/MetadataTypes/CustomApplication
    intersectMetadataType CustomApplication temp/MetadataTypes/CustomApplication

    # Data category group
    echo "======================= DataCategoryGroup ======================="
    rm -rf temp/MetadataTypes/DataCategoryGroup
    listMetadataType ${SOURCE_ORG} Source DataCategoryGroup temp/MetadataTypes/DataCategoryGroup
    listMetadataType ${TARGET_ORG} Target DataCategoryGroup temp/MetadataTypes/DataCategoryGroup
    intersectMetadataType DataCategoryGroup temp/MetadataTypes/DataCategoryGroup

    # Apex class
    echo "======================= ApexClass ======================="
    rm -rf temp/MetadataTypes/ApexClass
    listMetadataType ${SOURCE_ORG} Source ApexClass temp/MetadataTypes/ApexClass
    listMetadataType ${TARGET_ORG} Target ApexClass temp/MetadataTypes/ApexClass
    intersectMetadataType ApexClass temp/MetadataTypes/ApexClass

    # Apex page
    rm -rf temp/MetadataTypes/ApexPage
    echo "======================= ApexPage ======================="
    listMetadataType ${SOURCE_ORG} Source ApexPage temp/MetadataTypes/ApexPage
    listMetadataType ${TARGET_ORG} Target ApexPage temp/MetadataTypes/ApexPage
    intersectMetadataType ApexPage temp/MetadataTypes/ApexPage

    # Custom object
    rm -rf temp/MetadataTypes/CustomObject
    echo "======================= CustomObject ======================="
    listMetadataType ${SOURCE_ORG} Source CustomObject temp/MetadataTypes/CustomObject
    listMetadataType ${TARGET_ORG} Target CustomObject temp/MetadataTypes/CustomObject
    intersectMetadataType CustomObject temp/MetadataTypes/CustomObject

    # Custom field
    echo "======================= CustomField ======================="
    rm -rf temp/MetadataTypes/CustomField
    listMetadataType ${SOURCE_ORG} Source CustomField temp/MetadataTypes/CustomField
    listMetadataType ${TARGET_ORG} Target CustomField temp/MetadataTypes/CustomField
    subMetadataType CustomField temp/MetadataTypes/CustomField

    # Record type
    echo "======================= RecordType ======================="
    rm -rf temp/MetadataTypes/RecordType
    listMetadataType ${SOURCE_ORG} Source RecordType temp/MetadataTypes/RecordType
    listMetadataType ${TARGET_ORG} Target RecordType temp/MetadataTypes/RecordType
    subMetadataType RecordType temp/MetadataTypes/RecordType

    # Custom tab
    echo "======================= CustomTab ======================="
    rm -rf temp/MetadataTypes/CustomTab
    listMetadataType ${SOURCE_ORG} Source CustomTab temp/MetadataTypes/CustomTab
    listMetadataType ${TARGET_ORG} Target CustomTab temp/MetadataTypes/CustomTab
    intersectMetadataType CustomTab temp/MetadataTypes/CustomTab

    # Layout
    echo "======================= Layout ======================="
    rm -rf temp/MetadataTypes/Layout
    listMetadataType ${SOURCE_ORG} Source Layout temp/MetadataTypes/Layout
    listMetadataType ${TARGET_ORG} Target Layout temp/MetadataTypes/Layout
    intersectMetadataType Layout temp/MetadataTypes/Layout

    # External data source
    echo "======================= ExternalDataSource ======================="
    rm -rf temp/MetadataTypes/ExternalDataSource
    listMetadataType ${SOURCE_ORG} Source ExternalDataSource temp/MetadataTypes/ExternalDataSource
    listMetadataType ${TARGET_ORG} Target ExternalDataSource temp/MetadataTypes/ExternalDataSource
    intersectMetadataType ExternalDataSource temp/MetadataTypes/ExternalDataSource
    
    # User permission
    echo "======================= UserPermission ======================="
    rm -rf temp/MetadataTypes/UserPermission
    describeMetadataType ${SOURCE_ORG} Source Profile temp/MetadataTypes/UserPermission
    describeMetadataType ${TARGET_ORG} Target Profile temp/MetadataTypes/UserPermission
    subMetadataType UserPermission temp/MetadataTypes/UserPermission
}


#######################################
# listMetadataType : listing a metadata type
# Arguments:
#   org : alias of the org from which the metadata type will be listed
#   type : Source or Target
#   metadataType : metadata type name
#   metadataTypeFolder : metadata type target folder
#######################################
function listMetadataType(){

    org=$1
    type=$2
    metadataType=$3
    metadataTypeFolder=$4

    mkdir -p ${metadataTypeFolder}
    echo -ne "Listing ${metadataType} from ${org}(${type})... ⏳ "
    sfdx force:mdapi:listmetadata -u ${org} -m ${metadataType} -f ${metadataTypeFolder}/${type}.list.json &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError listMetadataType ${metadataType}"
        exit 1
    fi
    echo -e "\rListing ${metadataType} from ${org}(${type})... ✅ "
}

#######################################
# describeMetadataType : describe a metadata type
# Arguments:
#   org : alias of the org from which the metadata type will be listed
#   type : Source or Target
#   metadataType : metadata type name
#   metadataTypeFolder : metadata type target folder
#######################################
function describeMetadataType(){

    org=$1
    type=$2
    metadataType=$3
    metadataTypeFolder=$4

    mkdir -p ${metadataTypeFolder}
    echo -ne "Describing ${metadataType} from ${org}(${type})...⏳ "
    sfdx force:schema:sobject:describe -u ${org} -s ${metadataType} --json > ${metadataTypeFolder}/${type}.list.json
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError describeMetadataType ${metadataType}"
        exit 1
    fi
    echo -e "\rDescribing ${metadataType} from ${org}(${type})...✅ "
}



#######################################
# intersectMetadataType : intersect source & target list of a metadata type
# Arguments:
#   metadataType : metadata type name
#   metadataTypeFolder : metadata type target folder
#######################################
function intersectMetadataType(){

    metadataType=$1
    metadataTypeFolder=$2

    # intersect a metadataType
    echo -ne "Intersecting ${metadataType}...⏳ "
    ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=${metadataType} -PinputFile1Path=${metadataTypeFolder}/Source.list.json -PinputFile2Path=${metadataTypeFolder}/Target.list.json -PoutputFilePath=${metadataTypeFolder}/Intersect.list intersectMetadataLists &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError intersectMetadataType ${metadataType}"
        exit 1
    fi
    echo -e "\rIntersecting ${metadataType}...✅ "

}

#######################################
# subMetadataType : substruct source from target list of a metadata type
# Arguments:
#   metadataType : metadata type name
#   metadataTypeFolder : metadata type target folder
#######################################
function subMetadataType(){

    metadataType=$1
    metadataTypeFolder=$2

    # Subtract a metadataType
    echo -ne "Subtracting ${metadataType}...⏳ "
    ${GRADLE_BIN_PATH} -p ${GRADLE_BUILD_PATH} -PmetadataType=${metadataType} -PinputFile1Path=${metadataTypeFolder}/Source.list.json -PinputFile2Path=${metadataTypeFolder}/Target.list.json -PoutputFilePath=${metadataTypeFolder}/SourceSubTarget.list subMetadataLists &>/dev/null
    if [ $? -ne 0 ]
    then
        echo
        echo -e "\e[31mError SubtractMetadataType ${metadataType}"
        exit 1
    fi
    echo -e "\rSubtracting ${metadataType}...✅ "
}

# =================================== main ==================================
listProfileMetadataTypes
echo -e "\r\e[32mMetadatas successfully listed 🖨️"


