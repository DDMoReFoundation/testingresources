#' Executing PsN Execute followed by PsN VPC
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

#' Reading in the Model
#' =========================
setwd(mdlEditorHome)
setwd(projectPath)
mdlfile="models/Warfarin-ODE-latest.mdl"
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
	
#' We can then update the parameter object using the "update" function
	myParObjUpdated <- update(myParObj,block="STRUCTURAL",item=parNames[parNames%in%structuralNames],with=list(value=parValues[parNames%in%structuralNames]))
	myParObjUpdated <- update(myParObjUpdated,block="VARIABILITY",item=parNames[parNames%in%variabilityNames],with=list(value=parValues[parNames%in%variabilityNames]))
	
	myParObjUpdated
}



printMessage("Running Estimation (this can take about 5 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
baseSO <- estimate("models/Warfarin-ODE-latest.mdl", target="PsN", subfolder=.resultDir("PsNVPCTestScript-BaseModel"))

#' Populating the Parameter object with final estimates
myParObjUpdated=update.warfarin.params.with.final.estimates(parObj, bootSO)

#' Assembling the new MOG
myNewMOGforVPC <- createMogObj(dataObj = myDataObj, parObj = myParObjUpdated, mdlObj = myModObj, taskObj = myTaskObj, "Warfarin_ODE_latest_VPC")


printMessage("Running VPC (this can take about 5 minutes)")
setwd(mdlEditorHome)
setwd(projectPath)
vpcSO <- VPC.PsN(myNewMOGforVPC,samples=20, seed=1234, vpcOptions=" -threads=3", subfolder=.resultDir("PsNVPCTestScript-VPC"))


printMessage("Check if graph was produced")
printMessage("DONE")
