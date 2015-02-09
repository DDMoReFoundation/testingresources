#' Executing PsN Execute followed by PsN Bootstrap
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================
if(!exists(".MDL_WORKSPACE_PATH") || is.null(.MDL_WORKSPACE_PATH)) {
	stop(".MDL_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDL_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="PsN-Integration"
setwd(.MDL_WORKSPACE_PATH)
setwd(projectPath)
projectPath = getwd();

#' Fit a base model
#' -------------------------
printMessage("Running Estimation (this can take about 5 minutes)")
setwd(.MDL_WORKSPACE_PATH)
setwd(projectPath)
baseSO <- estimate("models/Warfarin-ODE-latest.mdl", target="PsN", subfolder=.resultDir("PsNBootstrapTestScript-BaseModel"))


printMessage("Running Bootstrap (this can take about 40 minutes)")
setwd(.MDL_WORKSPACE_PATH)
setwd(projectPath)
bootSO <- bootstrap.PsN("models/Warfarin-ODE-latest.mdl",samples=20, seed=1234, bootstrapOptions=" -threads=3", subfolder=.resultDir("PsNBootstrapTestScript-Bootstrap"))


printMessage("DONE")