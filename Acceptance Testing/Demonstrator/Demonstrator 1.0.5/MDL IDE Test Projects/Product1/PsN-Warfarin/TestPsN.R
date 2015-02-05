#' Using TEL functions, Monolix and Xpose in a workflow with a base model and a "full" model
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================
if(!exists("mdlEditorHome")||is.null(mdlEditorHome)) {
	mdlEditorHome= getwd();
}
projectPath="workspace/Product1/PsN-Warfarin";
setwd(mdlEditorHome)
setwd(projectPath)
projectPath = getwd();

#' List files available in working directory
list.files()

#' We can see the functions available in the TEL package
objects("package:DDMoRe.TEL")


#' Reading in the Model
#' =========================
setwd(mdlEditorHome)
setwd(projectPath)
mdlfile="Warfarin-ODE-latest.mdl"
myDataObj <- getDataObjects(mdlfile)[[1]]
myParObj <- getParameterObjects(mdlfile)[[1]]
myModObj <- getModelObjects(mdlfile)[[1]]
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]
dynamicMog=createMogObj(myDataObj, myParObj, myModObj, myTaskObj, "warfarin_from_mog")

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


#' Fit a base model
#' -------------------------
setwd(mdlEditorHome)
setwd(projectPath)
baseSO <- estimate("Warfarin-ODE-latest.mdl", target="PsN", subfolder="Base")

#' Run bootstrap
setwd(mdlEditorHome)
setwd(projectPath)
bootSO <- bootstrap.PsN("Base/Warfarin-ODE-latest.mdl",samples=20, seed=1234, bootstrapOptions=" -threads=3")

#' Assembling the new MOG
myNewMOGforVPC <- createMogObj(dataObj = myDataObj, parObj = myParObjUpdated, mdlObj = myModObj, taskObj = myTaskObj, "Warfarin-ODE-latest-VPC")

#' Run VPC with updated estimates
setwd(mdlEditorHome)
setwd(projectPath)
vpcSO <- VPC.PsN(myNewMOGforVPC,samples=20, seed=1234, vpcOptions=" -threads=3")

#' Run SSE
setwd(mdlEditorHome)
setwd(projectPath)
sseSO <- SSE.PsN("Base/Warfarin-ODE-latest.mdl",samples=20, seed=1234, sseOptions=" -no-estimate_simulation -threads=3")