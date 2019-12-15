


/*
* author : benahm
* description : Intersect metadata lists
*/

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction
import org.gradle.api.tasks.Input
import org.gradle.api.tasks.InputFile
import org.gradle.api.tasks.OutputFile

class IntersectMetadataLists extends DefaultTask {

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
        def interList = list1.intersect(list2);
        writeList(outputFile,interList);
    }

    // Read metadata list file
    def readMetadataList(inputFile) { 
        def list = [];

        if(!inputFile) return list;
        if(inputFile.text == 'undefined') return list;

        // loop through the inputFile
        def metadatas = new groovy.json.JsonSlurper().parseText(inputFile.text)
        if(metadatas instanceof List){
            metadatas.each{meta -> 
                list.add(meta.fullName)
            };
        }else {
            list.add(metadatas.fullName)
        }
        return list;
    }

    // write a list to a file
    def writeList(outputFile,list){
        outputFile.withWriter('UTF-8'){ writer ->
            list.each{ item ->
                 writer.println(item)
            }
        } 
    }

}