#' Executing Nonmem against supported models
#' =========================================================================================
#' =========================================================================================

library('mlxR')
library('ggplot2')

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="Smoke-Tests"
modelsDir="models/"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath=getwd()


mdlFileLocation=file.path(projectPath, modelsDir, "Claret_2009_oncology_capecitabine_TGI")
setwd(mdlFileLocation)

#' Set name of .mdl file
mdlfile="Claret_2009_oncology_capecitabine_TGI.mdl"


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

printMessage("Estimating with Nonmem")
soNonmem <- estimate(mdlfile, target="NONMEM", subfolder=.resultDir("NONMEM"));

if(length(soNonmem@TaskInformation$Messages$Errors)>0) {
	printMessage(paste("There were errors when executing model",mdlfile))
	print(soNonmem@TaskInformation$Messages$Errors)
	stop("Error, see console output for details")
}


printMessage("DONE")