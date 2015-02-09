#' Executing Nonmem against supported models
#' =========================================================================================
#' =========================================================================================

library('mlxR')
library('ggplot2')

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="NONMEM-Integration"
modelsDir="models/"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath=getwd()

#
# Test Models
#
models <- .getMDLFilesFromModelDirectory(modelsDir);

##
# Test Script
##

models.SO = lapply(models, function(modelFile) {
				setwd(projectPath)
				modelFile = paste(modelsDir,modelFile, sep="/");
				printMessage(paste("Running NONMEM with ", modelFile))
				names(model)
				so <- estimate(modelFile, target="NONMEM", subfolder=.resultDir("NONMEM"));
				
				printMessage("Please, verify that the execution did not fail")
				readline("Press <return to continue") 
				so
		});


printMessage("DONE")