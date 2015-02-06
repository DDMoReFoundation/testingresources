#' Using TEL functions, RNMImport, Xpose and PsN in a workflow
#' =========================
#'
#' author: "Roberto Bizzotto
#' -------------------------
#' ### date: `r date()`
#' 

#' Initialise
#' =========================

#' Uses Mango Solutions library RNMImport that reads in NONMEM files
#' and creates an R object
library(RNMImport)

library(xpose4)
library(lattice)

library(DDMoRe.TEL)

#' Clear workspace
rm(list=ls(all=T))

#' Set working directory
setwd("C:/Users/Roberto/Documents/2_Lavoro/DDMORE/WP2/StandaloneExecutionEnvironment/PKPDstick_72/MDL_IDE/workspace/drugX_intercative")

#' Helper functions for running this workflow: bs.summary() only at the moment 
#' (supplements TEL for now while functions are being developed)
source("workflowfunctions.R")

#' Set name of the mdl file
mdlfile="drugX_1stAbs_1occ_ORG.mdl"

#' Introduction to DDMoRe.TEL
#' =========================

#' We can see the functions available in the TEL package
objects("package:DDMoRe.TEL")

#' Files available in our working directory
list.files()

#' Parse the MDL and create a list of objects containig the information
parsed <- getMDLObjects(mdlfile)

#' Look at the names of the parsed objects
names(parsed)

#' We can now extract the objects from the list manually
mine_par <- parsed$drugX_par

#' Look at the type of objects
class(mine_par)

#' We can also just extract the data objects directly from the MDL
#' getDataObjects retrieves any objects in the file of type `data_ob{...}`
myParObj <- getParameterObjects(mdlfile)
class(myParObj)

#' The previous returns a list of one object, and we need the object itself rather than the list
myParObj <- myParObj[[1]]
class(myParObj)

#' Or, more quickly:
myParObj <- getParameterObjects(mdlfile)[[1]]
class(myParObj)

#' Let's look more closely at the parameter object
str(myParObj)

#' There are 2 "slots" in the object: STRUCTURAL and VARIABILITY (PRIOR is empty)
#' We can update this object using the "update" function
myParObjUpdated <- update(myParObj, block="STRUCTURAL", type="POP_Vc", with=list(value=12))
myParObjUpdated

#' Exploratory Data Analysis
#' =========================

#' Get MCL Data object, read and create R object (data frame)
#' -------------------------

#' Use TEL function getDataObjects to retrieve data object(s) from an existing .mdl file
myDataObj <- getDataObjects(mdlfile)[[1]]
myDataObj

#' Let's look at the MDL Data Object
myDataObj@SOURCE
myDataObj@DATA_INPUT_VARIABLES

#' `getDataObjects` just reads the .mdl file and parses the MCL code, it does not actually READ the data.
#' So the next step is to use the `read(...)` function to create an R object for the data
#' This may be useful in plotting and summarising
myData <- read(myDataObj,categoricalAsFactor = TRUE)

#' Showing first 6 lines of the data set.
head(myData)

#' Plot and summarise data using native (non-TEL) R commands
#' -------------------------
#' Extract only observation records
## (EDA stands for Exploratory Data Analysis)
myEDAData<-myData[myData$MDV==0,]

#' Plot data using xyplot from the lattice library
# windows()
xyplot(DV~TIME,groups=ID,data=myEDAData,type="b",ylab="Conc. (mg/L)",xlab="Time (h)")
xyplot(DV~TIME|ID,data=myEDAData,type="b",layout=c(5,5),
		ylab="Conc. (mg/L)",xlab="Time (h)",scales=list(relation="free"))

#' Run Original Model
#' =========================

#' Fit base model
#' -------------------------
#' We can execute an mdl file directly:
base <- estimate(mdlfile, target="NONMEM")#, subfolder="Model001")

#' For now, the results received will be in the form of an NMRun object 
#' (from the RNMImport package). In the future, a standardised object will be 
#' created which is compatible with other software (e.g. BUGS, PsN)
class(base)

#' As part of the TEL package, there will be many functions for working with the 
#' standardised output object. These functions are currently in development, but as
#' an example we can use the getEstimationInfo function
getEstimationInfo(base)

#' From here we use RNMImport to read the NONMEM output files
#' TEL functions will eventually replace these get<<...>> functions

#' Read the NONMEM output file using RNMImport and extract parameter estimates etc.
#' -------------------------
#' Once the model has run, RNMImport can be used to read and parse the output/log file

#' `get<<...>>` functions extract run information from the output/log file
#' The following functions are from the RNMImport package
#' `getObjective` (RNMImport) = `getEstimationInfo` (TEL)
getObjective(base)

#' `getThetas` (RNMImport) = `getParameters(type="Structural")` (TEL)
getThetas(base)
t(getThetas(base,what=c("initial","final","stderrors")))

#' Model diagnostics
#' -------------------------
#' Here Xpose (re)reads the NONMEM output from the run and creates an Xpose database object.
#' TEL will have a function `as.xpdb` which will convert the standardised output object to an Xpose database object,
#' so avoiding the need to re-read the NONMEM output again.

#' Extract control and output filenames from the RNMImport object
ctlFilename<-base@controlFileInfo$fileName
ctlFilename

lstFilename<-base@reportFileInfo$fileName
lstFilename

#' Extract the pathname and filenames from the above.
pathName<-dirname(ctlFilename)
pathName

fileName<-basename(ctlFilename)
fileName

#' native R commands. Look for sdtab etc. table files
runno <- as.numeric(gsub("[a-z]", "", list.files(path=pathName,pattern="^sdtab")[1]))
runno

#' Create Xpose Database object
#' -------------------------
#' Xpose has certain requirements for file naming
#' model file: run1.mod, run2.mod, ...

file.copy(ctlFilename,paste(pathName,"/run",runno,".mod",sep=""))
setwd(pathName)
base.xpdb<-xpose.data(runno)
#save(base.xpdb, file="Xpose database.RData")

#' Diagnostics using Xpose functions
#' -------------------------
# windows()
dv.vs.pred.ipred(base.xpdb)
pred.vs.idv(base.xpdb)

#' VPC simulation-based diagnostics using PsN
#' -------------------------
#' `VPC.PsN` is a TEL function which calls PsN.
#' The function is a wrapper to PsN's VPC function and simply passes the appropriate argument through to PsN.
#' Additional arguments for VPC using PsN can be passed as part of the `addargs` string.
#' Ultimately there will be a `VPC` method in TEL which is not tool specific. 
#' However, when the translation is NMTRAN and target software is PsN, then we will call VPC.PsN.

# fileName = relative path to CTL file
# mdlfile = relative path to MDL file
vpcout <- VPC.PsN(modelfile=mdlfile,nsamp=20,seed=123,
		addargs="--lst=output.lst --bin_by_count=1 --no_of_bins=6 --dir=VPCdir")

#' Plotting the VPC using the xpose.VPC function in xpose.
xpose.VPC(vpc.info=paste(vpcout$resultsDir,"/VPCdir/vpc_results.csv",sep=""),vpctab=paste(vpcout$resultsDir,"/VPCdir/vpctab",sep=""))

#' Bootstrap of the original model using PsN
#' -------------------------
#' Similarly to `VPC.PsN` here we can use the bootstrap functionality in PsN directly

bsout <- bootstrap.PsN(modelfile=mdlfile,nsamp=20,seed=123,addargs="--dir=BSdir")

bs.summary(paste(bsout$resultsDir,"/BSdir/bootstrap_results.csv",sep=""))

#' Simulation of the original model incorporating uncertainty
#' -------------------------
#' Here we use the bootstrap results as input to the VPC, effectively simulating using parameter uncertainty 
#' for the observed data structure.

# copy the raw results file to the current folder
rrFileName <- paste("raw_results_", sub("^([^.]*).*", "\\1", fileName), ".csv", sep="")
file.copy(paste(bsout$resultsDir,"/BSdir/",rrFileName,sep=""),rrFileName)
simout <- VPC.PsN(modelfile=mdlfile,nsamp=20,seed=123,addargs=paste("--rawres_input=",rrFileName," --dir=SIMdir",sep=""))

#' Plotting simulation using the xpose.VPC function in xpose.
xpose.VPC(vpc.info=paste(simout$resultsDir,"/SIMdir/vpc_results.csv",sep=""),vpctab=paste(simout$resultsDir,"/SIMdir/vpctab",sep=""))

#' Changing MOG items
#' =========================
#' We can change certain elements of the MOG (data, parameters, task) and re-run using the same model
#' This allows us to examine what happens when we fix parameters, change estimation methodology etc
#' If the model is set up appropriately we can test many different models simply by fixing or estimating different parameters

setwd("C:/Users/Roberto/Documents/2_Lavoro/DDMORE/WP2/StandaloneExecutionEnvironment/PKPDstick_72/MDL_IDE/workspace/DrugX003")

finalEstimates<-getThetas(base)
finalEstimates

myParObjUpdated <- update(myParObj, block="STRUCTURAL", type=c("POP_Vc","POP_Vp","POP_CL","POP_ka","POP_Q"), 
		with=list(value=as.vector(finalEstimates)))
myParObjUpdated

#' Use TEL function getModelObjects to retrieve model object(s) from an existing .mdl file
myModObj <- getModelObjects(mdlfile)[[1]]
myModObj

myNewTaskObj <- getTaskPropertiesObjects("drugX_1stAbs_1occ_SAEM_ORG.mdl")[[1]]
myNewTaskObj

myNewMOG <- createMogObj(dataObj = myDataObj, taskObj = myNewTaskObj, mdlObj = myModObj, parObj = myParObjUpdated)
myNewMOG

################## If the write method is finished:#############################
# We can then write the MOG back out to MDL:
# write(myNewMOG,"myNewMog.mdl")

# We can then execute this mdl file using NONMEM:
# # DON'T ESTIMATE THIS, IT TAKES TOO LONG!
# results2 <- estimate("myNewMog.mdl", target="NONMEM")

# Alternatively, we can execute the MOG directly without creating the mdl file:
# # DON'T ESTIMATE THIS, IT TAKES TOO LONG!
# results2 <- estimate(myNewMOG, target="NONMEM")
################################################################################

#' Producing an html report
#' =========================
#' Uses knitr library for dynamic report generation with R

# install.packages("knitr")
# library(knitr)
spin("drugX_TEL.r")
