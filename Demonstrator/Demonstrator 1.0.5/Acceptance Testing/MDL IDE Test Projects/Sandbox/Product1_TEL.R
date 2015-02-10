#' Using TEL functions, Monolix and Xpose in a workflow with a base model and a "full" model
#' =========================================================================================
#' =========================================================================================

#' Initialisation
#' =========================
if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="Sandbox";
setwd(mdlEditorHome)
setwd(projectPath)
projectPath = getwd()
setwd("models")
#' List files available in working directory
list.files()

#' Introduction to DDMoRe.TEL
#' =========================

#' We can see the functions available in the TEL package
objects("package:DDMoRe.TEL")



#' Set name of .mdl file
mdlfile="output.mdl"
myDataObj <- getDataObjects(mdlfile)[[1]]
myParObj <- getParameterObjects(mdlfile)[[1]]
myModObj <- getModelObjects(mdlfile)[[1]]
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]
mogForPsN=createMogObj(myDataObj, myParObj, myModObj, myTaskObj, "warfarin_from_mog")
setwd("..")
fromMogSO=estimate(mogForPsN, target = "PsN", subfolder="from-mdl-sse")


fromMogSSE_SO=SSE.PsN(mogForPsN,samples=20, seed=1234, sseOptions=" -no-estimate_simulation -threads=5")

#' Use TEL function getDataObjects() to retrieve data object(s) from an existing .mdl file
myDataObj <- getDataObjects(mdlfile)[[1]]

#' Let's look at the MCL data object
myDataObj

#' Use TEL function getParameterObjects() to retrieve parameter object(s) from an existing .mdl file
myParObj <- getParameterObjects(mdlfile)[[1]]

#' Let's look at the MCL parameter object
myParObj

#' Use TEL function getModelObjects() to retrieve model object(s) from an existing .mdl file
myModObj <- getModelObjects(mdlfile)[[1]]

#' Let's look at the MCL model object
myModObj

#' Use TEL function getTaskPropertiesObjects() to retrieve task properties object(s) from an existing .mdl file
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]

#' Let's look at the MCL task properties object
myTaskObj


#' Exploratory Data Analysis
#' =========================

#' Use TEL function read() to create an R object from the MCL data object
myData <- read(myDataObj)

#' Let's look at the first 6 lines of the data set
head(myData)

#' Extract only observation records
myEDAData<-myData[myData$MDV==0,]

#' Now plot the data using xyplot from the lattice library (graphs are exported to PDF)
pdf(file="EDA.pdf")
xyplot(DV~TIME,groups=ID,data=myEDAData,type="b",ylab="Conc. (mg/L)",xlab="Time (h)")
xyplot(DV~TIME|ID,data=myEDAData,type="b",layout=c(3,4),ylab="Conc. (mg/L)",xlab="Time (h)",scales=list(relation="free"))
dev.off()

#' Model Development
#' =========================

#' Fit a base model
#' -------------------------


setwd(mdlEditorHome)
setwd(projectPath)
mdlfile="Warfarin-ODE-latest.mdl"
myDataObj <- getDataObjects(mdlfile)[[1]]
myParObj <- getParameterObjects(mdlfile)[[1]]
myModObj <- getModelObjects(mdlfile)[[1]]
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]
dynamicMog=createMogObj(myDataObj, myParObj, myModObj, myTaskObj, "warfarin_from_mog")

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

#' Assembling the new MOG
myNewMOGforVPC <- createMogObj(dataObj = myDataObj, parObj = myParObjUpdated, mdlObj = myModObj, taskObj = myTaskObj, "Warfarin-ODE-latest-VPC")


setwd(mdlEditorHome)
setwd(projectPath)
vpcSO <- VPC.PsN(myNewMOGforVPC,samples=20, seed=1234, vpcOptions=" -threads=3")


setwd(mdlEditorHome)
setwd(projectPath)
base <- estimate("Warfarin-ODE-latest.mdl", target="PsN", subfolder="Base")



setwd(mdlEditorHome)
setwd(projectPath)
bootSO <- bootstrap.PsN("Base/Warfarin-ODE-latest.mdl",samples=20, seed=1234, bootstrapOptions=" -threads=3")


setwd(mdlEditorHome)
setwd(projectPath)
sseSO <- SSE.PsN("Base/Warfarin-ODE-latest.mdl",samples=20, seed=1234, sseOptions=" -no-estimate_simulation -threads=3")


#' Use TEL functions getEstimationInfo() and getParameterEstimates() to retrieve results via the standardised output object
getEstimationInfo(base)
getParameterEstimates(base)

#' Lower-level get() functions are also available
#DDMoRe.TEL:::getLikelihood(base)
#DDMoRe.TEL:::getPopulationEstimates(base)
#DDMoRe.TEL:::getPrecisionPopulationEstimates(base)
#DDMoRe.TEL:::getIndividualEstimates(base)
#DDMoRe.TEL:::getPrecisionIndividualEstimates(base)
#DDMoRe.TEL:::getResiduals(base)
#DDMoRe.TEL:::getPredictions(base)
#DDMoRe.TEL:::getRawResults(base)
#DDMoRe.TEL:::getToolSettings(base)
#DDMoRe.TEL:::getSoftwareMessages(base)

#' Perform model diagnostics for the base model using Xpose functions (graphs are exported to PDF)
#' -------------------------
pdf(file="GOF-base.pdf")

#' Use TEL function as.xpdb() to create an Xpose database object from the standardised output object
base.xpdb<-as.xpdb(base,"warfarin_conc.csv")

#' Plots of PRED and IPRED vs. DV and TIME
dv.vs.pred(base.xpdb)
dv.vs.ipred(base.xpdb)
pred.vs.idv(base.xpdb)
ipred.vs.idv(base.xpdb)

#' Plots of IWRES vs IPRED and TIME + histogram and qq-plot
absval.iwres.vs.ipred(base.xpdb)
absval.iwres.vs.idv(base.xpdb)
iwres.dist.hist(base.xpdb)
iwres.dist.qq(base.xpdb)

#' Plots of WRES vs PRED and TIME + histogram and qq-plot
wres.vs.pred(base.xpdb)
wres.vs.idv(base.xpdb)
wres.dist.hist(base.xpdb)
wres.dist.qq(base.xpdb)

#' Individual plots of DV, PRED and IPRED
ind.plots(base.xpdb)

#' Plots of ETAs
ranpar.splom(base.xpdb)
ranpar.hist(base.xpdb)
ranpar.qq(base.xpdb)
ranpar.vs.cov(base.xpdb)
dev.off()

#' Fit a "full" model with body weight as covariate on clearance and volume
#' -------------------------
#' We can update the parameter object using the "update" function
myParObjUpdated <- update(myParObj,block="STRUCTURAL",item=c("BETA_CL_WT","BETA_V_WT"),with=list(value=c(0.75,1)))

#' Let's look at the updated MCL parameter object
myParObjUpdated

#' Assembling the new MOG
myNewMOG <- createMogObj(dataObj = myDataObj, parObj = myParObjUpdated, mdlObj = myModObj, taskObj = myTaskObj)

#' We can then write the MOG back out to MDL
mdlfile.updated="Warfarin-ODE-latest-full.mdl"
write(myNewMOG,mdlfile.updated)

#' We can then execute this .mdl file
full <- estimate(mdlfile.updated, target="MONOLIX", subfolder="Full")

#' Use TEL functions getEstimationInfo() and getParameterEstimates() to retrieve results for comparison to the base model
getEstimationInfo(full)
getParameterEstimates(full)

#' Perform model diagnostics comparing the "full" model to the base model using Xpose functions (graphs are exported to PDF)
#' -------------------------
pdf(file="GOF-full.pdf")

#' Use TEL function as.xpdb() to create an Xpose database object
full.xpdb<-as.xpdb(full,"warfarin_conc.csv")

#' Plots of PRED and IPRED vs. DV and TIME
dv.vs.pred(full.xpdb)
dv.vs.ipred(full.xpdb)
pred.vs.idv(full.xpdb)
ipred.vs.idv(full.xpdb)

#' Plots of IWRES vs IPRED and TIME + histogram and qq-plot
absval.iwres.vs.ipred(full.xpdb)
absval.iwres.vs.idv(full.xpdb)
iwres.dist.hist(full.xpdb)
iwres.dist.qq(full.xpdb)

#' Plots of WRES vs PRED and TIME + histogram and qq-plot
wres.vs.pred(full.xpdb)
wres.vs.idv(full.xpdb)
wres.dist.hist(full.xpdb)
wres.dist.qq(full.xpdb)

#' Individual plots of DV, PRED and IPRED
ind.plots(full.xpdb)

#' Plots of ETAs
ranpar.splom(full.xpdb)
ranpar.hist(full.xpdb)
ranpar.qq(full.xpdb)
ranpar.vs.cov(full.xpdb)
dev.off()
