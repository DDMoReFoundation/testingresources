#' Executing PsN Execute followed by PsN Bootstrap
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

#' Fit a base model
#' -------------------------
printMessage("Running Estimation (this can take about 5 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
baseSO <- estimate("models/Warfarin-ODE-latest.mdl", target="PsN", subfolder=.resultDir("PsNBootstrapTestScript-BaseModel"))


printMessage("Running Bootstrap (this can take about 40 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
bootSO <- bootstrap.PsN("models/Warfarin-ODE-latest.mdl",samples=20, seed=1234, bootstrapOptions=" -threads=3", subfolder=.resultDir("PsNBootstrapTestScript-Bootstrap"))


printMessage("DONE")