#' Executing Monolix against the supported models.
#' =========================================================================================
#' =========================================================================================

# Initialization
if(!exists(".MDL_WORKSPACE_PATH") || is.null(.MDL_WORKSPACE_PATH)) {
	stop(".MDL_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDL_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="Monolix-Integration"
setwd(.MDL_WORKSPACE_PATH)
setwd(projectPath)
projectPath = getwd();


# Test Script

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
			printMessage(paste("Running MONOLIX with ", modelFile))
			names(model)
			so <- estimate(modelFile, target="MONOLIX", subfolder=.resultDir("MONOLIX"));
			printMessage("Please, verify that the execution did not fail")
			readline("Press <return to continue") 
			so
		});


printMessage("DONE")