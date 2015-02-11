#' Executing Monolix against the supported models.
#' =========================================================================================
#' =========================================================================================

# Initialization
if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="Monolix-Integration"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
modelsDir="models/"
projectPath = getwd()
models.SO = list()
models.validated = list()
models.xposedbs = list()

printMessage("Collecting list of models")
models <- .getMDLFilesFromModelDirectory(modelsDir)
printMessage(paste(models))

printMessage("Estimating models")
models.SO <- estimateModelsWith(models, "MONOLIX")

printMessage("Validating results of estimation")
models.validated <- validateExecutions(models.SO)

printMessage("Creating Xpose databases")
models.xposedbs <- createXposeDatabases(models.validated)

printMessage("DONE")