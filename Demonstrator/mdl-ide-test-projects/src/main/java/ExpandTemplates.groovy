/*******************************************************************************
 * Copyright (C) 2016 Mango Business Solutions Ltd, http://www.mango-solutions.com
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Affero General Public License as published by the
 * Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
 * for more details.
 *
 * You should have received a copy of the GNU Affero General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/agpl-3.0.html>.
 *******************************************************************************/
import static groovy.io.FileType.FILES

import org.apache.commons.io.FilenameUtils

/**
 * This script is responsible for expanding Test Script Templates and generating separate TestScript for each MDL use case
 */
def testProjectsSource = new File("./src/main/resources").getAbsoluteFile()
def testModelsDirs = [ (new File("./target/test-models/MDL/8.0.0").getAbsoluteFile()) : "models" ] 
def testProjectsTarget = new File("./target/testProjects").getAbsoluteFile()

println "Source Projects: ${testProjectsSource}"
println "Test Models Directories: ${testModelsDirs}"
println "Target Projects: ${testProjectsTarget}"
testProjectsTarget.mkdirs()

createInitialStructure(testProjectsSource, testProjectsTarget, testModelsDirs)

expandTemplates(testProjectsSource, testProjectsTarget, testModelsDirs)

def replaceTokens(text, binding) {
    binding.each { from, to ->
        text = text.replaceAll(/(\[${from}\])/, to)
    }
    return text
}

def createInitialStructure(testProjectsSource, testProjectsTarget, testModelsDirs) {
    testProjectsSource.eachDirMatch ({ !new File(it).name.contains("[") }) { sourceProject ->
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
            it.name =~ /.*test\.template.*/
        }
        
        mdlFiles.each { mdlFile ->
            modelName = FilenameUtils.getBaseName(mdlFile.getName())
            templates.each {
                def scriptFileName =  replaceTokens(it.getName(), ["MODEL_NAME" : FilenameUtils.getBaseName(mdlFile.getName())]).replaceAll("test\\.template", "test")
                def modelDirRelativePath = FilenameUtils.separatorsToUnix(it.getParentFile().toPath().relativize(mdlFile.getParentFile().toPath()).toString())
                println "Relative path to model file from R script is: ${modelDirRelativePath}"
                def binding = ["MODEL_DIR":modelDirRelativePath, "MODEL_FILE":mdlFile.getName(), "MODEL_NAME":modelName]
                def template = it.readLines().collect( {
                    line ->
                    replaceTokens(line, binding)
                }).join ("\n")
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