# PURPOSE: Test simcyp.generateMultiplePopulations function
# DESCRIPTION: Generate multiple populations.
# Based on https://sourceforge.net/p/ddmore/simcyp/ci/SimcypDemo/tree/SimcypDemoScript.R by Craig Lewin
# 
# Author: mrogalski
# Date: 29 Feb 2016
# Revision: 29 Feb 2016
# Tags: simcyp, generate, populations, multiple
# Order: 600
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
    stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Simcyp")
projectPath=getwd()

run ({
context(paste("Simcyp","-","simcyp.generateMultiplePopulations function"))

test_that("Generates a SIM-OBESE population of 100 individuals", {
            popIds <- simcyp.getPopulationIDs()

            multiPop1_SO <- simcyp.generateMultiplePopulations(c(popIds[[2]], popIds[[10]]), c(75, 50))

            expect_false(class(multiPop1_SO)=="try-error", "Doesn't crash with errors")
            expect_equal(length(multiPop1_SO@TaskInformation@ErrorMessages),0, "There are No errors in SO")
            expect_false(is.null(multiPop1_SO@Simulation$SimulationBlock@SimulatedProfiles[[1]]@data), "SimulatedProfiles' data is populated")

        }
)

test_that("Don't embed data in standard output", {
            popIds <- simcyp.getPopulationIDs()

            multiPop2_SO <- simcyp.generateMultiplePopulations(c(popIds[[3]], popIds[[6]], 
                                                            popIds[[8]], popIds[[16]]), 250, FALSE)

            expect_false(class(multiPop2_SO)=="try-error", "Doesn't crash with errors")
            expect_equal(length(multiPop2_SO@TaskInformation@ErrorMessages),0, "There are No errors in SO")
            expect_false(is.null(multiPop2_SO@Simulation$SimulationBlock@SimulatedProfiles[[1]]@data), "SimulatedProfiles' data is populated")

       }
)

})

