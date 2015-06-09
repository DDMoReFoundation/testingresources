#' Executing Nonmem against supported models
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="NONMEM-Integration"
modelsDir="models/"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath=getwd()
models.SO = list()
models.validated = list()

selectSupported <- function(models) {
	supportedModels = list("UseCase1.mdl", "UseCase5_1.mdl")
	models[unlist(lapply(models, function (x) { x %in% supportedModels } ))]
}

printMessage("Collecting list of models")
models <- .getMDLFilesFromModelDirectoryFlat(modelsDir)
printMessage(paste(models))
printMessage("Estimating models")
models.SO <- estimateModelsWith(selectSupported(models), "NONMEM")


printMessage("Validating results of estimation")
models.validated <- verifyExecutions(models.SO)

printMessage("Creating Xpose databases")
models.xposedbs <- createXposeDatabases(models.validated)


printMessage("DONE")