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
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath = getwd();

#' Reading in the Model
#' =========================
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
mdlfile="models/Warfarin-ODE/Warfarin-ODE-latest.mdl"
myDataObj <- getDataObjects(mdlfile)[[1]]
myParObj <- getParameterObjects(mdlfile)[[1]]
myModObj <- getModelObjects(mdlfile)[[1]]
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]
dynamicMog=createMogObj(myDataObj, myParObj, myModObj, myTaskObj, "warfarin_from_mog")


printMessage("Running Estimation (this can take about 5 minutes)")
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
baseSO <- estimate(dynamicMog, target="PsN", subfolder=.resultDir("PsNEstimateFromMOGTestScript-BaseModel"))

printMessage("DONE")