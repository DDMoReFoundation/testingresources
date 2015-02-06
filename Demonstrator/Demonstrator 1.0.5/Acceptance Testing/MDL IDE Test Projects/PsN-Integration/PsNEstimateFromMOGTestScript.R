#' Executing PsN Execute against a MOG
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================
if(!exists("mdlEditorHome")||is.null(mdlEditorHome)) {
	mdlEditorHome= getwd();
}
projectPath=.prependWithWorkspaceIfNeeded("PsN-Integration");
setwd(mdlEditorHome)
setwd(projectPath)
source(file.path(mdlEditorHome,"Test-Utils/utils/utils.R"));
projectPath = getwd();

#' Reading in the Model
#' =========================
setwd(mdlEditorHome)
setwd(projectPath)
mdlfile="models/Warfarin-ODE-latest.mdl"
myDataObj <- getDataObjects(mdlfile)[[1]]
myParObj <- getParameterObjects(mdlfile)[[1]]
myModObj <- getModelObjects(mdlfile)[[1]]
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]
dynamicMog=createMogObj(myDataObj, myParObj, myModObj, myTaskObj, "warfarin_from_mog")


printMessage("Running Estimation (this can take about 5 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
baseSO <- estimate(dynamicMog, target="PsN", subfolder="PsNEstimateFromMOGTestScript-BaseModel")

printMessage("DONE")