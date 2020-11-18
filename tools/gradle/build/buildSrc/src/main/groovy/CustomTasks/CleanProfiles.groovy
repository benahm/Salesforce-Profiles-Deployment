

/*
* author : benahm
* description : Clean profiles
*/

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFile
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.Optional
import org.gradle.api.tasks.OutputDirectory
import org.gradle.api.tasks.InputDirectory

class CleanProfiles extends DefaultTask {
    @Input 
    String metadataType
    @InputFile
    File cleanFile
    @InputDirectory
    @OutputDirectory
    File profileFolder

    @TaskAction
    def action() {
        def cleanMap = [:]
        if(metadataType == 'DataCategoryGroup'){
            cleanMap['categoryGroupVisibilities.dataCategoryGroup'] = []
            cleanFile.eachLine { line, count ->
                line = "$line".trim();
                cleanMap['categoryGroupVisibilities.dataCategoryGroup'].add(line)
            }
        }
        if(metadataType == 'CustomField'){
            cleanMap['fieldPermissions.field'] = []
            cleanFile.eachLine { line, count ->
                line = "$line".trim();
                if(line.startsWith("Activity")){
                    cleanMap['fieldPermissions.field'].add("Event." + Utility.substringAfter("$line","."))
                    cleanMap['fieldPermissions.field'].add("Task." + Utility.substringAfter("$line","."))
                }
                cleanMap['fieldPermissions.field'].add(line)
            }
        }else if(metadataType == 'CustomTab'){
            cleanMap['tabVisibilities.tab'] = []
            cleanFile.eachLine { line, count ->
                line = "$line".trim();
                cleanMap['tabVisibilities.tab'].add(line)
            }
        }else if(metadataType == 'RecordType'){
            cleanMap['recordTypeVisibilities.recordType'] = []
            cleanMap['layoutAssignments.recordType'] = []
            cleanFile.eachLine { line, count ->
                line = "$line".trim();
                cleanMap['recordTypeVisibilities.recordType'].add(line)
                cleanMap['layoutAssignments.recordType'].add(line)
            }
        }else if(metadataType == 'UserPermission'){
            cleanMap['userPermissions.name'] = []
            cleanFile.eachLine { line, count ->
                line = "$line".trim();
                cleanMap['userPermissions.name'].add(line)
            }
        }
        profileFolder.eachFile{profileFile ->
            clean(profileFile,cleanMap);
        }
    }

    // clean nodes from XML file
    def clean(profileFile,cleanMap) {
        
        def xml = new groovy.util.XmlSlurper(false,false).parseText(profileFile.text); 
        def rt = []

        cleanMap.each{ key, list ->
            def node = getProperty(xml,key)
            def nodeToDelete = node.findAll{ elem ->
                // disabled need more tests
                // if(key == 'recordTypeVisibilities.recordType'){
                //     // collect sobject that have no default record type
                //     if(elem.parent().default == 'true' || elem.parent().personAccountDefault == 'true'){
                //         def sObjectType = Utility.substringBefore(elem.parent().recordType.text(),".")
                //         rt.add(sObjectType)
                //     }
                // }
                return list.contains(elem.text()) 
            }
            def parent = nodeToDelete.parent()
            parent.replaceNode { } // clean
        }
        
        // disabled need more tests
        // set record types visible and default to false if the default record type was cleaned
        // def node = getProperty(xml,'recordTypeVisibilities.recordType')
        // node.each{ elem ->
        //     def sObjectType = Utility.substringBefore(elem.parent().recordType.text(),".")
        //     if(rt.contains(sObjectType)){
        //         // set to not visible/default
        //         elem.parent().default = "false"
        //         elem.parent().personAccountDefault = "false"
        //         elem.parent().visible = "false"
        //     }
        // }

        profileFile.write groovy.xml.XmlUtil.serialize(xml)

    }

    // dynamically get a property from the xml object
    def getProperty(object, String property) {
        property.tokenize('.').inject object, {obj, prop ->    
            def value = obj[prop]
            if(value.size() == 0)
                println ("Warning : tag $prop not found in the xml input file ${obj[prop]}")
            return value
        }  
    }

}