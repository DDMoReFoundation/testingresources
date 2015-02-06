#' Executing PsN Execute followed by PsN SSE
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================
if(!exists("mdlEditorHome")||is.null(mdlEditorHome)) {
	mdlEditorHome= getwd();
}
projectPath="workspace/PsN-Integration/Warfarin-ODE";
setwd(mdlEditorHome)
setwd(projectPath)
source("../utils/utils.R")
projectPath = getwd();

printMessage("Running Estimation (this can take about 5 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
baseSO <- estimate("Warfarin-ODE-latest.mdl", target="PsN", subfolder="PsNSSETestScript-BaseModel")


printMessage("Running SSE (this can take about 3 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
sseSO <- SSE.PsN("Warfarin-ODE-latest.mdl",samples=20, seed=1234, sseOptions=" -no-estimate_simulation -threads=3", subfolder="PsNSSETestScript-SSE")

printMessage("DONE")