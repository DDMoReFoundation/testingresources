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
modelsDir="models/"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath = getwd();

models <- .getMDLFilesFromModelDirectoryFlat(modelsDir)
# We just need to check one model as part of system tests.
model <- models[[1]]
mdlfile <- file.path(modelsDir,model)

printMessage("Running SSE (this can take about 3 minutes)")
sseSO <- SSE.PsN(mdlfile,samples=20, seed=1234, sseOptions=" -no-estimate_simulation -threads=3", subfolder=.resultDir(paste0("PsNSSETestScript-SSE-",model)))

testSummary()