#' Executing PsN Execute followed by PsN Bootstrap
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

#' Fit a base model
#' -------------------------
printMessage("Running Estimation (this can take about 5 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
baseSO <- estimate("Warfarin-ODE-latest.mdl", target="PsN", subfolder="PsNBootstrapTestScript-BaseModel")


printMessage("Running Bootstrap (this can take about 40 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
bootSO <- bootstrap.PsN("Warfarin-ODE-latest.mdl",samples=20, seed=1234, bootstrapOptions=" -threads=3", subfolder="PsNBootstrapTestScript-Bootstrap")


printMessage("DONE")