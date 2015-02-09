#' Executing Monolix against the supported models.
#' =========================================================================================
#' =========================================================================================

# Initialization
if(!exists("mdlEditorHome")||is.null(mdlEditorHome)) {
	mdlEditorHome= getwd();
}
source(file.path(mdlEditorHome,"Test-Utils/utils/utils.R"));

projectPath="Monolix-Integration"
setwd(mdlEditorHome)
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