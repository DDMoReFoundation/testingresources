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
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath = getwd();

printMessage("Running Estimation (this can take about 5 minutes)")
baseSO <- estimate("models/Warfarin-ODE/Warfarin-ODE-latest.mdl", target="PsN", subfolder=.resultDir("PsNBootstrapTestScript-BaseModel"))

printMessage("Running Bootstrap (this can take about 40 minutes)")
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
bootSO <- bootstrap.PsN("models/Warfarin-ODE/Warfarin-ODE-latest.mdl",samples=20, seed=1234, bootstrapOptions=" -threads=3", subfolder=.resultDir("PsNBootstrapTestScript-Bootstrap"))


printMessage("DONE")