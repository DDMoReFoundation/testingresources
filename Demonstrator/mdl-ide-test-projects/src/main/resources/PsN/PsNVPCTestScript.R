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
	supportedModels = list("models/UseCase2.mdl")
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
#' Extract MLE values from the "nm" object 
	parValues <- getPopulationParameters(soObj, what="estimates")$MLE
#' Get the names of the returned parameters
	parNames <- names(parValues)
#' The Parameter Object blocks are supplied as slots in the (S4) object of class "parObj".  
#' Extract the parameter names from the STRUCTURAL block in the Parameter Object.
	structuralNames <- names(myParObj@STRUCTURAL)
#' Extract the parameter names from the VARIABILITY block in the Parameter Object.
	variabilityNames <- names(myParObj@VARIABILITY)
	
#' In the current version of the SO standard, we need to manually update parameter names for correlation and
#' covariance parameters to match the SO with the MDL. This will not be needed in future releases.
#' The SO object returned from NONMEM has parameter PPV_CL_PPV_V. 
#' This needs to be renamed to conform to model Correlation name OMEGA
	parNames[grep("PPV_CL_PPV_V", parNames)] <- grep("OMEGA",variabilityNames,value=T) 
	
#' We can then update the parameter object using the "updateParObj" function
	myParObjUpdated <- updateParObj(myParObj,block="STRUCTURAL",item=parNames[parNames%in%structuralNames],with=list(value=parValues[parNames%in%structuralNames]))
	myParObjUpdated <- updateParObj(myParObjUpdated,block="VARIABILITY",item=parNames[parNames%in%variabilityNames],with=list(value=parValues[parNames%in%variabilityNames]))
#' A bug in the writeMogObj function means that for now, we must manually add the square bracket around the OMEGA value
#' to signify that this is a vector (of length 1).
	#' myParObjUpdated@VARIABILITY$OMEGA$value<-paste0("[",myParObjUpdated@VARIABILITY$OMEGA$value,"]")
	myParObjUpdated
}

printMessage("Running Estimation (this can take about 5 minutes)")
baseSO <- estimate(mdlfile, target="PsN", subfolder=.resultDir(paste0("PsNVPCTestScript-Base-",basename(mdlfile))))

verifyEstimate(baseSO)

printMessage("Populating the Parameter object with final estimates")
myParObjUpdated=update.warfarin.params.with.final.estimates(myParObj, baseSO)

printMessage("Assembling the new mog")
myNewMOGforVPC <- createMogObj(dataObj = myDataObj, parObj = myParObjUpdated, mdlObj = myModObj, taskObj = myTaskObj, "Warfarin_ODE_latest_VPC")

printMessage("Running VPC (this can take about 5 minutes)")
myNewMogFile<-file.path(getwd(),"models/Warfarin_ODE_latest_VPC.mdl")
writeMogObj(myNewMOGforVPC,myNewMogFile)
vpcSO <- VPC.PsN(myNewMogFile,samples=20, seed=1234, vpcOptions=" -threads=3", subfolder=.resultDir(paste0("PsNVPCTestScript-VPC-",basename(mdlfile))));

printMessage("Check if the graph was produced")

testSummary()
