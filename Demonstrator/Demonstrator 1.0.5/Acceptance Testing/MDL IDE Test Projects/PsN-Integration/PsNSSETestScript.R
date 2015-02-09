#' Executing PsN Execute followed by PsN SSE
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================
if(!exists("mdlEditorHome")||is.null(mdlEditorHome)) {
	mdlEditorHome= getwd();
}
source(file.path(mdlEditorHome,"Test-Utils/utils/utils.R"));

projectPath=.prependWithWorkspaceIfNeeded(mdlEditorHome,"PsN-Integration");
setwd(mdlEditorHome)
setwd(projectPath)
projectPath = getwd();

printMessage("Running Estimation (this can take about 5 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
baseSO <- estimate("models/Warfarin-ODE-latest.mdl", target="PsN", subfolder=.resultDir("PsNSSETestScript-BaseModel"))


printMessage("Running SSE (this can take about 3 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
sseSO <- SSE.PsN("models/Warfarin-ODE-latest.mdl",samples=20, seed=1234, sseOptions=" -no-estimate_simulation -threads=3", subfolder=.resultDir("PsNSSETestScript-SSE"))

printMessage("DONE")