#' Executing PsN Execute against a MOG
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

selectSupported <- function(models) {
	supportedModels = list("UseCase1.mdl", "UseCase5_1.mdl")
	models[unlist(lapply(models, function (x) { x %in% supportedModels } ))]
}

models <- .getMDLFilesFromModelDirectoryFlat(modelsDir);
#We just need to check one.
model <- selectSupported(models)[[1]]
mdlfile <- file.path(modelsDir,model)

printMessage("Reading the model")
myDataObj <- getDataObjects(mdlfile)[[1]]
myParObj <- getParameterObjects(mdlfile)[[1]]
myModObj <- getModelObjects(mdlfile)[[1]]
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]

printMessage("Create a MOG")
dynamicMog=createMogObj(myDataObj, myParObj, myModObj, myTaskObj, "execute_mog")

printMessage("Running Estimation (this can take about 5 minutes)")
baseSO <- estimate(dynamicMog, target="PsN", subfolder=.resultDir(paste0("PsNEstimateFromMOGTestScript-",model)))

verifyEstimate(baseSO)

printMessage("DONE")