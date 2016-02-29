# PURPOSE: Test simcyp.generateSinglePopulation functions
# DESCRIPTION: Generate single population.
# Based on https://sourceforge.net/p/ddmore/simcyp/ci/SimcypDemo/tree/SimcypDemoScript.R by Craig Lewin
#
# Author: mrogalski
# Date: 29 Feb 2016
# Revision: 29 Feb 2016
# Tags: simcyp, generate, population, single
# Order: 600
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
    stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Simcyp")
projectPath=getwd()

run ({
context(paste("Simcyp","-","simcyp.generateSinglePopulation function"))

test_that("Generates a SIM-OBESE population of 100 individuals", {
            setwd(createSubDirectory("simcyp.generateSinglePopulation-test1", projectPath))
            popIds <- simcyp.getPopulationIds()
            
            singlePop1_SO <- simcyp.generateSinglePopulation(popIds[[11]], 100)
            
            expect_false(class(singlePop1_SO)=="try-error", "Doesn't crash with errors")
            resultsDir<-simcyp.getResultsDirectory()
            expect_false(is.null(list.files(resultsDir)), "SOME content in results directory") 
            expect_false(is.null(list.files(resultsDir,pattern="simcyp_standard_output\\.xml$")), "SO file exists")
            expect_true(is.null(singlePop1_SO@TaskInformation$Messages$Errors), "There are no errors in SO")
            expect_false(is.null(singlePop1_SO@Simulation@SimulationBlock$SimulationBlock@SimulatedProfiles$data), "SimulatedProfiles' data is populated")
       }
)

test_that("Don't embed data in standard output", {
            setwd(createSubDirectory("simcyp.generateSinglePopulation-test2", projectPath))
            popIds <- simcyp.getPopulationIds()
            
            singlePop2_SO <- simcyp.generateSinglePopulation(popIds[[7]], 0, FALSE)
            
            expect_false(class(singlePop2_SO)=="try-error", "Doesn't crash with errors")
            resultsDir<-simcyp.getResultsDirectory()
            expect_false(is.null(list.files(resultsDir)), "SOME content in results directory") 
            expect_false(is.null(list.files(resultsDir,pattern="simcyp_standard_output\\.xml$")), "SO file exists")
            expect_true(is.null(singlePop2_SO@TaskInformation$Messages$Errors), "There are no errors in SO")
            expect_false(is.null(singlePop2_SO@Simulation@SimulationBlock$SimulationBlock@SimulatedProfiles$data), "SimulatedProfiles' data is populated")
       }
)

test_that("Just selected outputs included in the SO", {
            setwd(createSubDirectory("simcyp.generateSinglePopulation-test3", projectPath))
            popIds <- simcyp.getPopulationIds()
            outIds <- simcyp.getOutputIds()
            
            singlePop3_SO <- simcyp.generateSinglePopulation(popIds[[7]], 1000, outputIds = c(outIds[[5]], outIds[[7]]))
            
            expect_false(class(singlePop3_SO)=="try-error", "Doesn't crash with errors")
            resultsDir<-simcyp.getResultsDirectory()
            expect_false(is.null(list.files(resultsDir)), "SOME content in results directory") 
            expect_false(is.null(list.files(resultsDir,pattern="simcyp_standard_output\\.xml$")), "SO file exists")
            expect_true(is.null(singlePop3_SO@TaskInformation$Messages$Errors), "There are no errors in SO")
            expect_false(is.null(singlePop3_SO@Simulation@SimulationBlock$SimulationBlock@IndivParameters$data), "IndivParameters' data is populated")
       }
)
})
