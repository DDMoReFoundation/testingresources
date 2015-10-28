#' Executing PsN Execute followed by PsN VPC
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

selectSupported <- function(models) {
	supportedModels = list("models/UseCase1.mdl", "models/UseCase5_1.mdl")
	models[unlist(lapply(models, function (x) { x %in% supportedModels } ))]
}

models <- .getMDLFilesFromModelDirectoryFlat()
# We just need to check one model as part of system tests.
mdlfile <- selectSupported(models)[[1]]

printMessage("Reading in the Model")
myDataObj <- getDataObjects(mdlfile)[[1]]
myParObj <- getParameterObjects(mdlfile)[[1]]
myModObj <- getModelObjects(mdlfile)[[1]]
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]

#
# Encapsulated update of the Model parameters from the Standard Output
#
update.warfarin.params.with.final.estimates <- function(parObj, soObj) {
	temp <- baseSO@Estimation@PopulationEstimates$MLE$data
	parValues <- as.numeric(temp[1,])
	parNames <- names(as.data.frame(temp))
	structuralNames <- c("POP_CL","POP_V","POP_KA","POP_TLAG")
	variabilityNames <- c("PPV_CL","PPV_V","PPV_KA","PPV_TLAG","RUV_PROP","RUV_ADD", "CORR_PPV_CL_V")
	
#' We can then update the parameter object using the "updateParObj" function
	myParObjUpdated <- updateParObj(myParObj,block="STRUCTURAL",item=parNames[parNames%in%structuralNames],with=list(value=parValues[parNames%in%structuralNames]))
	myParObjUpdated <- updateParObj(myParObjUpdated,block="VARIABILITY",item=parNames[parNames%in%variabilityNames],with=list(value=parValues[parNames%in%variabilityNames]))
	
	myParObjUpdated
}


printMessage("Running Estimation (this can take about 5 minutes)")
baseSO <- estimate(mdlfile, target="PsN", subfolder=.resultDir(paste0("PsNVPCTestScript-Base-",basename(model))))

verifyEstimate(baseSO)

printMessage("Populating the Parameter object with final estimates")
myParObjUpdated=update.warfarin.params.with.final.estimates(parObj, bootSO)

printMessage("Assembling the new mog")
myNewMOGforVPC <- createMogObj(dataObj = myDataObj, parObj = myParObjUpdated, mdlObj = myModObj, taskObj = myTaskObj, "Warfarin_ODE_latest_VPC")

printMessage("Running VPC (this can take about 5 minutes)")
vpcSO <- VPC.PsN(myNewMOGforVPC,samples=20, seed=1234, vpcOptions=" -threads=3", subfolder=.resultDir(paste0("PsNVPCTestScript-VPC-",basename(model))));

printMessage("Check if the graph was produced")

testSummary()
