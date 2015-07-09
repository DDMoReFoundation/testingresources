#' Executing PsN Execute followed by PsN Bootstrap
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================
if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));
projectPath="PsN-Integration"
modelsDir="models/"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath = getwd();

printMessage("Running Bootstrap (this can take about 40 minutes)")
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)

selectSupported <- function(models) {
	supportedModels = list("models/UseCase1.mdl", "models/UseCase5_1.mdl")
	models[unlist(lapply(models, function (x) { x %in% supportedModels } ))]
}

models <- .getMDLFilesFromModelDirectoryFlat()
# We just need to check one model as part of system tests.
mdlfile <- selectSupported(models)[[1]]

bootSO <- bootstrap.PsN(mdlfile,samples=20, seed=1234, bootstrapOptions=" -threads=3", subfolder=.resultDir(paste0("PsNBootstrapTestScript-Bootstrap-",basename(mdlfile))))

testSummary()