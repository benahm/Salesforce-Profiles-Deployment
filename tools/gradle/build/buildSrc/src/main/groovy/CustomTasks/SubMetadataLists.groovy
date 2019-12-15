


/*
* author : benahm
* description : Subtract metadata lists
*/

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFile
import org.gradle.api.tasks.OutputFile

class SubMetadataLists extends DefaultTask {

    @InputFile
    File inputFile1
    @InputFile
    File inputFile2
    @OutputFile
    File outputFile

    @TaskAction
    def action() {
        def list1 = readMetadataList(inputFile1)
        def list2 = readMetadataList(inputFile2)
        list1.removeAll(list2);
        writeList(outputFile,list1);
    }

    // Read metadata list file
    def readMetadataList(inputFile) { 
        def list = [];
        def reg = ~/^Permissions/   

        if(!inputFile) return list;
        if(inputFile.text == 'undefined') return list;

        // loop through the inputFile
        def metadatas = new groovy.json.JsonSlurper().parseText(inputFile.text)
        if(metadatas instanceof List){
            metadatas.each{meta -> 
                list.add(meta.fullName)
            };
        }else {
            if(metadatas.result){
                metadatas.result.fields.each{ meta ->
                    list.add(meta.name - reg)
                }
            }else
                list.add(metadatas.fullName)
        }
        return list;
    }

    // Write a list to a file
    def writeList(outputFile,list){
        outputFile.withWriter('UTF-8'){ writer ->
            list.each{ item ->
                 writer.println(item)
            }
        } 
    }

}