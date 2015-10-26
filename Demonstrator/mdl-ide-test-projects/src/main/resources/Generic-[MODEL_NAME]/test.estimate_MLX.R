# PURPOSE: Test TEL MDL reading functions
# DESCRIPTION: Reads MDL file and checks that objects are of correct type and structure
# TODO: 
# 
# Author: smith_mk
# Date: 03 Aug 2015
# Tags: execution, monolix, [MODEL_NAME]
# Revisions: 
# Order: 100
###############################################################################
#' Initialisation
#' =========================
if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Generic-[MODEL_NAME]")
projectPath=getwd()

run ({
case<-"[MODEL_DIR]/[MODEL_NAME]"
contextDetail <- "Monolix"
context(paste(case,"-",contextDetail))
mdlfile <- getModel(case)

test_that(paste("Estimating",case,"with Monolix"), {
			target <- "MONOLIX"
			executionId <- format(Sys.time(),"%H%M%S")
			resultDir <- getResultDir(case,target, id = executionId)
			resultDirName <- basename(resultDir)
			mlx <- try(estimate(mdlfile, target=target, subfolder=resultDirName))
			expect_false(class(mlx)=="try-error", "estimate doesn't crash with errors")
			print(mlx)
			expect_false(is.null(list.files(resultDir)), "There is SOME content in subfolder")
			expect_false(is.null(list.files(resultDir,pattern="\\.SO.xml$")), "SO file exists")
			expect_true(is.null(mlx@TaskInformation$Messages$Errors), "There are No errors") 
			expect_false(is.null(mlx@Estimation@PopulationEstimates$MLE$data), "MLE values are populated")
			expect_false(is.null(mlx@Estimation@Likelihood$LogLikelihood), "Log-Likelihood value is populated")
			
			if(!testthat:::get_reporter()$failed) {
				#If any of the above tests failed, don't promote the result (i.e. don't make it available for subsequent tests)
				promoteResult(case, resultDir, target)
			}
			
			if(FALSE) {
				#skipping as this is not yet supported
				myParObj <- getParameterObjects(mdlfile)[[1]]
				myParObjNames <- c(names(myParObj@STRUCTURAL),
						names(myParObj@VARIABILITY) )
				mySONames <- names(getPopulationParameters(mlx)$MLE)
				
				expect_true(setequal(myParObjNames, mySONames), paste("SO parameters and ParameterObject elements differ:", paste(setdiff(myParObjNames, mySONames), collapse=",")))
			}
		}
	)
})