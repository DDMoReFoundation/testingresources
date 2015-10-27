/*******************************************************************************
 * Copyright (C) 2015 Mango Solutions Ltd - All rights reserved.
 ******************************************************************************/
import static groovy.io.FileType.FILES

import org.apache.commons.io.FileUtils
import org.apache.commons.io.FilenameUtils

/**
 * This script is responsible for expanding Test Script Templates and generating separate TestScript for each MDL use case
 */
def testProjectsSource = new File("./src/main/resources").getAbsoluteFile()
def testModelsDirs = [ (new File("./target/test-models/MDL/7.0.0").getAbsoluteFile()) : "models" ] 
def testProjectsTarget = new File("./target/testProjects").getAbsoluteFile()

println "Source Projects: ${testProjectsSource}"
println "Test Models Directories: ${testModelsDirs}"
println "Target Projects: ${testProjectsTarget}"
testProjectsTarget.mkdirs()

createInitialStructure(testProjectsSource, testProjectsTarget, testModelsDirs)

expandTemplates(testProjectsSource, testProjectsTarget, testModelsDirs)

def isTestProjectTemplate(String filePath) {
    return new File(filePath).name.contains("[")
}

def createInitialStructure(testProjectsSource, testProjectsTarget, testModelsDirs) {
    testProjectsSource.eachDirMatch ( {isTestProjectTemplate(it)} ) { sourceProject ->
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
def replaceTokens(String text, Map binding) {
    binding.each { from, to ->
        text = text.replaceAll("\\[${from}\\]", to)
    }
    return text
}

def expandTemplates(testProjectsSource, testProjectsTarget, testModelsDirs) {
    testProjectsTarget.eachDirMatch ( {isTestProjectTemplate(it)} ) { testProjectTemplate ->
        def mdlFiles = []
        testProjectTemplate.eachFileRecurse(FILES, {mdlFiles << it} )
        
        mdlFiles = mdlFiles.findAll {
            it.name =~ /.*\.mdl/
        }
        
        mdlFiles.each {
            mdlFile ->
            modelName = FilenameUtils.getBaseName(mdlFile.getName())
            File targetProject = new File(testProjectsTarget, replaceTokens(testProjectTemplate.getName(), ["MODEL_NAME" : modelName]))
            println "Copying ${testProjectTemplate} to ${targetProject}"
            
            new AntBuilder().copy( todir: targetProject) {
                fileset( dir: testProjectTemplate ) {
                    include (name:"**/*")
                }
            }
            
            def scripts = []
            targetProject.eachFileRecurse(FILES, {scripts << it} )
            
            scripts = scripts.findAll {
                it.name =~  /.*\.R/
            }
            
            mdlFileLocation = testProjectTemplate.toPath().relativize(mdlFile.toPath()).toString()
            mdlFileInNewProject = new File(targetProject, mdlFileLocation)
            scripts.each { script ->
                println "Processing R script ${script}"
                def modelDirRelativePath = FilenameUtils.separatorsToUnix(script.getParentFile().toPath().relativize(mdlFileInNewProject.getParentFile().toPath()).toString())
                println "Relative path to model file from R script is: ${modelDirRelativePath}"
                def binding = ["MODEL_NAME": modelName, "MODEL_DIR": modelDirRelativePath, "MODEL_FILE":mdlFile.getName()]
                def template = replaceTokens(script.text, binding)
                script.write(template)
            }
            
            // expanding .project file template
            File projectDescriptor = new File(targetProject, ".project")
            def binding = ["MODEL_NAME": modelName]
            def template = replaceTokens(projectDescriptor.text, binding)
            projectDescriptor.write(template)
        }
    }
    
    testProjectsTarget.eachDirMatch ( {isTestProjectTemplate(it)}) { testProjectTemplate ->
        println "removing ${testProjectTemplate}";
        FileUtils.deleteDirectory(testProjectTemplate)
    }
}

