# PURPOSE: Test TEL bootstrap
# DESCRIPTION: Runs bootstrap with PsN
#   and provides an automated test that each case runs successfully. 
#   NB: DOES NOT test that the answer is *correct*, just that there are no errors
# TODO: 
# 
# Author: smith_mk
# Date: 14 August 2015
# Tags: execution, psn, bootstrap, [MODEL_NAME]
# Order: 300
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Generic-[MODEL_NAME]")
projectPath=getwd()

run ({
case<-"[MODEL_DIR]/[MODEL_NAME]"
contextDetail <- "Bootstrap"
context(paste(case,"-",contextDetail))
mdlfile <- getModel(case)

test_that(paste("bootstrap",case), {
			target <- "BOOTSTRAP"
			resultDir <- getResultDir(case,target)
			resultDirName <- basename(resultDir)
			bootstrap <- try(bootstrap.PsN(mdlfile, samples=20, seed=876543,
							bootstrapOptions=" -no-skip_minimization_terminated -threads=3",
							subfolder=resultDirName) )
			expect_false(class(bootstrap)=="try-error", "bootstrap.PsN Doesn't crash")
			expect_is(bootstrap,"StandardOutputObject", "Bootstrap result should be an S4 class StandardOutputObject")

			# 
			expect_false(is.null(bootstrap@Estimation@PopulationEstimates@OtherMethod$Bootstrap@Mean@data), "Mean is populated")
			expect_false(is.null(bootstrap@Estimation@PopulationEstimates@OtherMethod$Bootstrap@Median@data), "Median is populated")
			expect_false(is.null(bootstrap@Estimation@PrecisionPopulationEstimates@OtherMethod$Bootstrap@PercentilesCI@data), "Percentiles are populated")

			# ADD TEST FOR ASYMPTOTIC RESULTS AND CIs
			# expect_false(is.null(bootstrap@Estimation@PrecisionPopulationEstimates$Bootstrap$Percentiles$data))
			
			expect_false(is.null(getPopulationParameters(bootstrap)$Bootstrap), "getPopulationParameters returns appropriate values")

			
			
			if(!testthat:::get_reporter()$failed) {
				#If any of the above tests failed, don't promote the result (i.e. don't make it available for subsequent tests)
				promoteResult(case, resultDir, target)
			}
			
			if(FALSE) {
				bootstrapNames <- getPopulationParameters(bootstrap)$Bootstrap$Parameter
				parameterNames <- c(names(getParameterObjects(mdlfile)[[1]]@STRUCTURAL), names(getParameterObjects(mdlfile)[[1]]@VARIABILITY))
				expect_identical(bootstrapNames, parameterNames, " All parameters should have a bootstrap result")
			}
		}
)
})
		