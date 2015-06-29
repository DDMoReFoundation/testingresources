#' Executing Nonmem against supported models
#' =========================================================================================
#' =========================================================================================

#' Initialisation
if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="BasicFunctionality"
modelsDir="models/"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath=getwd()


mdlFileLocation=file.path(projectPath, "$MODEL_DIR")
setwd(mdlFileLocation)


mdlfile="$MODEL_FILE"
printMessage(paste("Working with", mdlfile))


printMessage("List objects in the environment")
objects("package:DDMoRe.TEL")


printMessage("Loading in data object(s)")
myDataObj <- getDataObjects(mdlfile)[[1]]


printMessage("Data object:")
myDataObj

printMessage("Loading parameter object(s)")
myParObj <- getParameterObjects(mdlfile)[[1]]

printMessage("Parameter object:")
myParObj

printMessage("Loading model object(s)")
myModObj <- getModelObjects(mdlfile)[[1]]

printMessage("Model object:")
myModObj

printMessage("Loading Task Properties object(s)")
myTaskObj <- getTaskPropertiesObjects(mdlfile)[[1]]

printMessage("Task Properties object:")
myTaskObj

printMessage("Reading in data from Data Object")
myData <- read(myDataObj)

printMessage("Data contents:")
head(myData)

testSummary()
