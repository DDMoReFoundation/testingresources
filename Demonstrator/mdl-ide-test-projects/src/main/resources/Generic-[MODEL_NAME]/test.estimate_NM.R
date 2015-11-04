# PURPOSE: Test TEL estimate
# DESCRIPTION: Runs estimation with Monolix / NONMEM
#   and provides an automated test that each case runs successfully. 
#   NB: DOES NOT test that the answer is *correct*, just that there are no errors
# TODO: 
#   In testing as.xpdb need to find a good way to check expected rows in xpdb vs rawData
# 
# Author: smith_mk
# Date: 13 May 2015
# Tags: execution, nonmem, [MODEL_NAME]
# Order: 100
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Generic-[MODEL_NAME]")
projectPath=getwd()

run ({
case<-"[MODEL_DIR]/[MODEL_NAME]"
contextDetail <- "Nonmem"
context(paste(case,"-",contextDetail))
mdlfile <- getModel(case)

test_that(paste("Estimating",case,"with NONMEM"), {
			target <- "NONMEM"
			executionId <- format(Sys.time(),"%H%M%S")
			resultDir <- getResultDir(case,target, id = executionId)
			resultDirName <- basename(resultDir)
			nm <- try(estimate(mdlfile, target=target, subfolder=resultDirName))
			expect_false(class(nm)=="try-error", "estimate doesn't crash with errors")
			expect_false(is.null(list.files(resultDir)), "SOME content in subfolder") 
			expect_false(is.null(list.files(resultDir,pattern="\\.SO.xml$")), "SO file exists")
			expect_true(is.null(nm@TaskInformation$Messages$Errors), "There are No errors in SO")
			expect_false(is.null(nm@Estimation@PopulationEstimates$MLE$data), "MLE values are populated")
			expect_false(is.null(nm@Estimation@Likelihood$Deviance), "Log-Likelihood value is populated")
			
			if(!testthat:::get_reporter()$failed) {
				#If any of the above tests failed, don't promote the result (i.e. don't make it available for subsequent tests)
				promoteResult(case, resultDir, target)
			}
			if(FALSE) {
				# turned off as not yet supported
				myParObj <- getParameterObjects(mdlfile)[[1]]
				myParObjNames <- c(names(myParObj@STRUCTURAL),
						names(myParObj@VARIABILITY) )
				mySONames <- names(getPopulationParameters(nm)$MLE)
				expect_true(setequal(myParObjNames, mySONames), paste("SO parameters and ParameterObject elements differ:", paste(setdiff(myParObjNames, mySONames), collapse=",")))
			}
		}
)
})
