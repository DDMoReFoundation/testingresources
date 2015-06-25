/*******************************************************************************
 * Copyright (C) 2015 Mango Solutions Ltd - All rights reserved.
 ******************************************************************************/
import static groovy.io.FileType.FILES

import org.apache.commons.io.FilenameUtils
/**
 * This script is responsible for expanding Test Script Templates and generating separate TestScript for each MDL use case
 */
def testProjectsSource = new File("./src/main/resources").getAbsoluteFile()
def testModelsDirs = [ (new File("./target/test-models/MDL/Product4").getAbsoluteFile()) : "models",
                        (new File("./target/test-models/MDL/CNS").getAbsoluteFile()) : "cns" ] 
def testProjectsTarget = new File("./target/testProjects").getAbsoluteFile()

println "Source Projects: ${testProjectsSource}"
println "Test Models Directories: ${testModelsDirs}"
println "Target Projects: ${testProjectsTarget}"
testProjectsTarget.mkdirs()

createInitialStructure(testProjectsSource, testProjectsTarget, testModelsDirs)

expandTemplates(testProjectsSource, testProjectsTarget, testModelsDirs)


def createInitialStructure(testProjectsSource, testProjectsTarget, testModelsDirs) {
    testProjectsSource.eachDir { sourceProject ->
        File targetProject = new File(testProjectsTarget, sourceProject.getName() )
        println "Copying ${sourceProject} to ${targetProject}"
        
        new AntBuilder().copy( todir: targetProject) {
            fileset( dir: sourceProject ) {
                include (name:"**/*")
            }
        }
        
        testModelsDirs.each { source, target ->
            def targetModels = new File(targetProject, target)
            println "Copying ${source} to ${targetModels}"
            new AntBuilder().copy( todir: targetModels) {
                fileset( dir: source )
              }
        }
    }
}

def expandTemplates(testProjectsSource, testProjectsTarget, testModelsDirs) {
    testProjectsTarget.eachDir {
        def mdlFiles = []
        it.eachFileRecurse(FILES, {mdlFiles << it} )
        
        mdlFiles = mdlFiles.findAll {
            it.name =~ /.*\.mdl/
        }
        
        def templates = it.listFiles().findAll {
            it.name =~ /.*TestScriptTemplate\.R/
        }
        
        mdlFiles.each { mdlFile ->
            templates.each {
                def scriptFileName =  Eval.me("MODEL_NAME", FilenameUtils.getBaseName(mdlFile.getName()), "\"${it.getName()}\"").replaceAll("Template\\.R", ".R")
                def binding = ["MODEL_DIR":it.getParentFile().toPath().relativize(mdlFile.getParentFile().toPath()), "MODEL_FILE":mdlFile.getName()]
                def engine = new groovy.text.SimpleTemplateEngine()
                def template = engine.createTemplate(it.text).make(binding)
                new File(it.getParentFile(), scriptFileName).write(template.toString())
            }
        }
        
        // removing the templates
        templates.each {
             println "removing ${it}";
             it.delete()
             }
    }
}