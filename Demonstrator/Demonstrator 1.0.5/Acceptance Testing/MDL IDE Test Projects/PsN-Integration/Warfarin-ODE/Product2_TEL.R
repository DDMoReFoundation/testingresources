#' Using TEL functions, Monolix, NONMEM and Xpose in a workflow with an initial estimation
#' step in Monolix and a subsequent estimation step in NONMEM (using the final estimates
#' from Monolix is initial estimates in NONMEM)
#' =========================================================================================
#' =========================================================================================


#' Initialisation
#' =========================

#' Clear workspace
rm(list=ls(all=T))

#' Set working directory
setwd("workspace/Product2/models")

#' List files available in working directory
list.files()

#' Set name of .mdl file
mdlfile="Warfarin-ODE-latest-Monolix.mdl"


#' Introduction to DDMoRe.TEL
#' =========================

#' We can see the functions available in the TEL package
objects("package:DDMoRe.TEL")

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

#' Fit the model in Monolix
#' -------------------------
#' Execute estimation in Monolix
monolix <- estimate(mdlfile, target="MONOLIX", subfolder="Monolix")

#' Use TEL functions getEstimationInfo() and getParameterEstimates() to retrieve results via the standardised output object
getEstimationInfo(monolix)
getParameterEstimates(monolix)

#' Lower-level get() functions are also available
#DDMoRe.TEL:::getLikelihood(monolix)
#DDMoRe.TEL:::getPopulationEstimates(monolix)
#DDMoRe.TEL:::getPrecisionPopulationEstimates(monolix)
#DDMoRe.TEL:::getIndividualEstimates(monolix)
#DDMoRe.TEL:::getPrecisionIndividualEstimates(monolix)
#DDMoRe.TEL:::getResiduals(monolix)
#DDMoRe.TEL:::getPredictions(monolix)
#DDMoRe.TEL:::getRawResults(monolix)
#DDMoRe.TEL:::getToolSettings(monolix)
#DDMoRe.TEL:::getSoftwareMessages(monolix)

#' Perform model diagnostics for the Monolix model using Xpose functions (graphs are exported to PDF)
#' -------------------------
pdf(file="GOF-Monolix.pdf")

#' Use TEL function as.xpdb() to create an Xpose database object from the standardised output object
monolix.xpdb<-as.xpdb(monolix,"warfarin_conc.csv")

#' Plots of PRED and IPRED vs. DV and TIME
dv.vs.pred(monolix.xpdb)
dv.vs.ipred(monolix.xpdb)
pred.vs.idv(monolix.xpdb)
ipred.vs.idv(monolix.xpdb)

#' Plots of IWRES vs IPRED and TIME + histogram and qq-plot
absval.iwres.vs.ipred(monolix.xpdb)
absval.iwres.vs.idv(monolix.xpdb)
iwres.dist.hist(monolix.xpdb)
iwres.dist.qq(monolix.xpdb)

#' Plots of WRES vs PRED and TIME + histogram and qq-plot
wres.vs.pred(monolix.xpdb)
wres.vs.idv(monolix.xpdb)
wres.dist.hist(monolix.xpdb)
wres.dist.qq(monolix.xpdb)

#' Individual plots of DV, PRED and IPRED
ind.plots(monolix.xpdb)

#' Plots of ETAs
ranpar.splom(monolix.xpdb)
ranpar.hist(monolix.xpdb)
ranpar.qq(monolix.xpdb)
ranpar.vs.cov(monolix.xpdb)
dev.off()

#' Use the final estimates from Monolix as initial estimates for estimation in NONMEM
#' -------------------------
#' We can retrieve the parameter names and final estimates from Monolix
#' using a lower-level get() function and a bit of extra code  
temp <- DDMoRe.TEL:::getPopulationEstimates(monolix)
temp <- temp$MLE$data
parValues <- as.numeric(temp[1,])
parNames <- names(as.data.frame(temp))
structuralNames <- c("POP_CL","POP_V","POP_KA","POP_TLAG")
variabilityNames <- c("PPV_CL","PPV_V","PPV_KA","PPV_TLAG","RUV_PROP","RUV_ADD")

#' We can then update the parameter object using the "update" function
myParObjUpdated <- update(myParObj,block="STRUCTURAL",item=parNames[parNames%in%structuralNames],with=list(value=parValues[parNames%in%structuralNames]))
myParObjUpdated <- update(myParObjUpdated,block="VARIABILITY",item=parNames[parNames%in%variabilityNames],with=list(value=parValues[parNames%in%variabilityNames]))

#' The name of the correlation parameter 'CORR_PPV_CL_V' is different in the SO ('r_V_CL'), and needs to be handled differently 
myParObjUpdated <- update(myParObjUpdated,block="VARIABILITY",item="CORR_PPV_CL_V",with=list(value=parValues[parNames%in%"r_V_CL"]))

#' Let's now look at the updated MCL parameter object
myParObjUpdated

#' Assembling the new MOG
myNewMOG <- createMogObj(dataObj = myDataObj, parObj = myParObjUpdated, mdlObj = myModObj, taskObj = myTaskObj)

#' We can then write the MOG back out to MDL
mdlfile.updated="Warfarin-ODE-latest-NONMEM.mdl"
write(myNewMOG,mdlfile.updated)

#' We can then execute this .mdl file in NONMEM
nonmem <- estimate(mdlfile.updated, target="NONMEM", subfolder="NONMEM")

#' Use TEL functions getEstimationInfo() and getParameterEstimates() to retrieve results for comparison to the Monolix model
getEstimationInfo(nonmem)
getParameterEstimates(nonmem)

#' Perform model diagnostics for the NONMEM model using Xpose functions (graphs are exported to PDF)
#' -------------------------
pdf(file="GOF-NONMEM.pdf")

#' Use TEL function as.xpdb() to create an Xpose database object
nonmem.xpdb<-as.xpdb(nonmem,"warfarin_conc.csv")

#' Plots of PRED and IPRED vs. DV and TIME
dv.vs.pred(nonmem.xpdb)
dv.vs.ipred(nonmem.xpdb)
pred.vs.idv(nonmem.xpdb)
ipred.vs.idv(nonmem.xpdb)

#' Plots of IWRES vs IPRED and TIME + histogram and qq-plot
absval.iwres.vs.ipred(nonmem.xpdb)
absval.iwres.vs.idv(nonmem.xpdb)
iwres.dist.hist(nonmem.xpdb)
iwres.dist.qq(nonmem.xpdb)

#' Plots of WRES vs PRED and TIME + histogram and qq-plot
wres.vs.pred(nonmem.xpdb)
wres.vs.idv(nonmem.xpdb)
wres.dist.hist(nonmem.xpdb)
wres.dist.qq(nonmem.xpdb)

#' Individual plots of DV, PRED and IPRED
ind.plots(nonmem.xpdb)

#' Plots of ETAs
ranpar.splom(nonmem.xpdb)
ranpar.hist(nonmem.xpdb)
ranpar.qq(nonmem.xpdb)
ranpar.vs.cov(nonmem.xpdb)
dev.off()
