#' Using TEL functions, RNMImport, Xpose and PsN in a workflow
#' =========================
#'
#' author: "Roberto Bizzotto
#' -------------------------
#' ### date: `r date()`
#' 

#' Initialise
#' =========================

#' Set working directory
setwd("workspace/Product1/models")

#' Helper functions for running this workflow: bs.summary() only at the moment 
#' (supplements TEL for now while functions are being developed)
#' source("workflowfunctions.R")

#' Set names of the mdl files
mdlfile="Warfarin-ODE-latest.mdl"
newmdlfile="Warfarin-ODE-latest-MOG-written.mdl"

#' Parse the MDL and create a list of objects containig the information
#' parsed <- getMDLObjects(mdlfile)

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
myData <- read(myDataObj)

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

#' Retrieve (first) parameter model object(s) from an existing .mdl file
myParObj <- getParameterObjects(mdlfile)[[1]]
myParObj

#' Retrieve (first) model object from an existing .mdl file
myModObj <- getModelObjects(mdlfile)[[1]]
myModObj

#' Retrieve task-properties object(s) from an existing .mdl file
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]
myTaskObj

#'
#' Run Original Model
#' =========================

#' Fit base model
#' -------------------------
#' We can execute an mdl file directly:
#' base <- estimate(mdlfile, target="NONMEM")#, subfolder="Model001")
base <- estimate(mdlfile, target="MONOLIX")#, subfolder="Model001")

#' Fit "full" model with body weight as covariate on clearance and volume
#' -------------------------
#' We can update the parameter object using the "update" function
myParObj@STRUCTURAL$BETA_CL_WT
myParObj@STRUCTURAL$BETA_V_WT

myParObjUpdated <- update(myParObj,block="STRUCTURAL",item=c("BETA_CL_WT","BETA_V_WT"),with=list(value=c(0,0)))

#' Let's look at the updated MCL parameter object
myParObjUpdated
myParObjUpdated@STRUCTURAL$BETA_CL_WT
myParObjUpdated@STRUCTURAL$BETA_V_WT

#' Create new MOG from previously retrieved MCL blocks
#' -------------------------
myNewMOG <- createMogObj(dataObj = myDataObj, taskObj = myTaskObj, mdlObj = myModObj, parObj = myParObjUpdated)
myNewMOG

write(myNewMOG, newmdlfile)

#'
#' Run New MOG Model
#' =========================
base <- estimate(newmdlfile, target="MONOLIX")#, subfolder="Model001")
