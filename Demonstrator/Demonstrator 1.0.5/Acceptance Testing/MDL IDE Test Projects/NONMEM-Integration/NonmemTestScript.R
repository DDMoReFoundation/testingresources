#' Executing Nonmem against supported models
#' =========================================================================================
#' =========================================================================================

library('mlxR')
library('ggplot2')

if(!exists("mdlEditorHome") || is.null(mdlEditorHome)) {
	mdlEditorHome=getwd()
}
setwd(mdlEditorHome)
projectPath=.prependWithWorkspaceIfNeeded("NONMEM-Integration")
modelsDir="models/"
setwd(projectPath)
source(file.path(mdlEditorHome,"Test-Utils/utils/utils.R"));
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