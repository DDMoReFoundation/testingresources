# PURPOSE: Test simcyp.generateSinglePopulation functions
# DESCRIPTION: Generate single population.
# Based on https://sourceforge.net/p/ddmore/simcyp/ci/SimcypDemo/tree/SimcypDemoScript.R by Craig Lewin
# 
# Author: mrogalski
# Date: 29 Feb 2016
# Revision: 29 Feb 2016
# Tags: simcyp, simulation
# Order: 600
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
    stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Simcyp")
projectPath=getwd()

workspaceFile<-file.path(projectPath,"test.wksz")

run ({
context(paste("Simcyp","-","simcyp.simulate function"))

test_that("Simulate Backman workspace", {
            setwd(createSubDirectory("simcyp.simulate-test1", projectPath))
            
            sim1_SO <- simcyp.simulate(file_path_as_absolute(workspaceFile))
            
            expect_false(class(sim1_SO)=="try-error", "Doesn't crash with errors")
            resultsDir<-simcyp.getResultsDirectory()
            expect_false(is.null(list.files(resultsDir)), "SOME content in results directory") 
            expect_false(is.null(list.files(resultsDir,pattern="simcyp_standard_output\\.xml$")), "SO file exists")
            expect_true(is.null(multiPop1_SO@TaskInformation$Messages$Errors), "There are no errors in SO")
            expect_false(is.null(multiPop1_SO@Simulation@SimulationBlock$SimulationBlock@SimulatedProfiles$data), "SimulatedProfiles' data is populated")
       }
)

test_that("Don't embed data in standard output", {
            setwd(createSubDirectory("simcyp.simulate-test2", projectPath))
            
            sim2_SO <- simcyp.simulate(file_path_as_absolute(workspaceFile), FALSE)
            expect_false(class(sim2_SO)=="try-error", "Doesn't crash with errors")
            resultsDir<-simcyp.getResultsDirectory()
            expect_false(is.null(list.files(resultsDir)), "SOME content in results directory") 
            expect_false(is.null(list.files(resultsDir,pattern="simcyp_standard_output\\.xml$")), "SO file exists")
            expect_true(is.null(sim2_SO@TaskInformation$Messages$Errors), "There are no errors in SO")
            expect_false(is.null(sim2_SO@Simulation@SimulationBlock$SimulationBlock@SimulatedProfiles$data), "SimulatedProfiles' data is populated")
        }
)
})











