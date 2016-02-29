# PURPOSE: Test simcyp.get*Ids functions
# DESCRIPTION: Get the lists of available population IDs and output IDs.
# Based on https://sourceforge.net/p/ddmore/simcyp/ci/SimcypDemo/tree/SimcypDemoScript.R by Craig Lewin
# 
# Author: mrogalski
# Date: 29 Feb 2016
# Revision: 29 Feb 2016
# Tags: simcyp, get
# Order: 600
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
    stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Simcyp")
projectPath=getwd()

run ({
context(paste("Simcyp","-","simcyp.test* functions"))

test_that("simcyp.getPopulationIds returns list of population ids", {
            popIds <- simcyp.getPopulationIds()
            expect_is(popIds, "list")
            expect_true(length(popIds)>0, "Expect some ids have been generated")
        }
)

test_that("simcyp.getOutputIds returns list of output ids", {
            outIds <- simcyp.getOutputIds()
            expect_is(outIds, "list")
            expect_true(length(outIds)>0, "Expect some ids have been generated")
        }
)
})
