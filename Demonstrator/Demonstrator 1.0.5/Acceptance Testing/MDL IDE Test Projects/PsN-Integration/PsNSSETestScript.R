#' Executing PsN Execute followed by PsN SSE
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

printMessage("Running Estimation (this can take about 5 minutes)")
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
baseSO <- estimate("models/Warfarin-ODE-latest.mdl", target="PsN", subfolder=.resultDir("PsNSSETestScript-BaseModel"))


printMessage("Running SSE (this can take about 3 minutes)")
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
sseSO <- SSE.PsN("models/Warfarin-ODE-latest.mdl",samples=20, seed=1234, sseOptions=" -no-estimate_simulation -threads=3", subfolder=.resultDir("PsNSSETestScript-SSE"))

printMessage("DONE")