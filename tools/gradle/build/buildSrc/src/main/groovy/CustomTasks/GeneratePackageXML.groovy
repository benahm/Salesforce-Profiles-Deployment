


/*
* author : benahm
* description : Generate a package xml from a list of metadata types files
*/

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFile
import org.gradle.api.tasks.OutputFile
import org.gradle.api.tasks.Optional

class GeneratePackageXML extends DefaultTask {
    
    @Input
    String apiVersion
    @InputFile
    @Optional
    File inputCustomApplicationListFile
    @InputFile
    @Optional
    File inputDataCategoryGroupListFile
    @InputFile
    @Optional
    File inputApexClassListFile
    @InputFile
    @Optional
    File inputApexPageListFile
    @InputFile
    @Optional
    File inputCustomObjectListFile
    @InputFile
    @Optional
    File inputCustomTabListFile
    @InputFile
    @Optional
    File inputLayoutListFile
    @InputFile
    @Optional
    File inputExternalDataSourceListFile
    @InputFile
    @Optional
    File inputProfileListFile
    @OutputFile
    File outputPackageXMLFile

    @TaskAction
    def action() {
        def metadatTypeMap = [:]
        def customApplicationList = readList(inputCustomApplicationListFile)
        def dataCategoryGroupList = readList(inputDataCategoryGroupListFile)
        def apexClassList = readList(inputApexClassListFile)
        def apexPageList = readList(inputApexPageListFile)
        def customObjectList = readList(inputCustomObjectListFile)
        def customTabList = readList(inputCustomTabListFile)
        def layoutList = readList(inputLayoutListFile)
        def externalDataSourceList = readList(inputExternalDataSourceListFile)
        def profileList = readList(inputProfileListFile)
        metadatTypeMap['CustomApplication'] = customApplicationList
        metadatTypeMap['DataCategoryGroup'] = dataCategoryGroupList
        metadatTypeMap['ApexClass'] = apexClassList
        metadatTypeMap['ApexPage'] = apexPageList
        metadatTypeMap['CustomObject'] = customObjectList
        metadatTypeMap['CustomTab'] = customTabList
        metadatTypeMap['Layout'] = layoutList
        metadatTypeMap['ExternalDataSource'] = externalDataSourceList
        metadatTypeMap['Profile'] = profileList
        def xmlContent = xmlContent(metadatTypeMap)
        println "XML generated : \n $xmlContent"
    }

    // Parse input file
    def readList(inputFile) {
        def list = [];

        if(!inputFile) return list;

        // loop through the inputFile
        inputFile.eachLine { line, count ->
            line = "$line".trim()
            list.add(line);
        }
        return list;
    }

    // Generate package xml
    def xmlContent(metadataTypeMap){

        def sw = new StringWriter()
        def xml = new groovy.xml.MarkupBuilder(sw)
        xml.mkp.xmlDeclaration(version: "1.0", encoding: "UTF-8")

        xml.Package(xmlns:"http://soap.sforce.com/2006/04/metadata"){
            if(!metadataTypeMap['CustomApplication'].empty){
                types(){
                    metadataTypeMap['CustomApplication'].each({ item ->
                        members(item)
                    })
                    name('CustomApplication')
                }
            }
            if(!metadataTypeMap['DataCategoryGroup'].empty){
                types(){
                    metadataTypeMap['DataCategoryGroup'].each({ item ->
                        members(item)
                    })
                    name('DataCategoryGroup')
                }
            }
            if(!metadataTypeMap['ApexClass'].empty){
                types(){
                    metadataTypeMap['ApexClass'].each({ item ->
                        members(item)
                    })
                    name('ApexClass')
                }
            }
            if(!metadataTypeMap['ApexPage'].empty){
                types(){
                    metadataTypeMap['ApexPage'].each({ item ->
                        members(item)
                    })
                    name('ApexPage')
                }
            }
            if(!metadataTypeMap['CustomObject'].empty){
                types(){
                    metadataTypeMap['CustomObject'].each({ item ->
                        members(item)
                    })
                    name('CustomObject')
                }
            }
            if(!metadataTypeMap['CustomTab'].empty){
                types(){
                    metadataTypeMap['CustomTab'].each({ item ->
                        members(item)
                    })
                    name('CustomTab')
                }
            }
            if(!metadataTypeMap['Layout'].empty){
                types(){
                    metadataTypeMap['Layout'].each({ item ->
                        members(item)
                    })
                    name('Layout')
                }
            }
            if(!metadataTypeMap['ExternalDataSource'].empty){
                types(){
                    metadataTypeMap['ExternalDataSource'].each({ item ->
                        members(item)
                    })
                    name('ExternalDataSource')
                }
            }
            if(!metadataTypeMap['Profile'].empty){
                types(){
                    metadataTypeMap['Profile'].each({ item ->
                        members(item)
                    })
                    name('Profile')
                }
            }
            'version'(apiVersion)
        }

        def xmlContent = sw.toString();

        outputPackageXMLFile.withWriter('UTF-8'){ writer ->
            writer.write(xmlContent)
        } 

        return xmlContent
    }

}