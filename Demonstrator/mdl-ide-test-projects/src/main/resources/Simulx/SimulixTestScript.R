#' Executing Simulx
#' =========================================================================================
#' =========================================================================================
stop("Simulx integration is not yet supported by the Framework.")


library('mlxR')
library('ggplot2')

#' Initialisation
#' =========================
if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="Simulix-Integration"
modelsDir="models"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath=getwd()


printMessage("Loading models list")
source("SimulixModelsListInit.R")


printMessage("Convert Models to PharmML")
models.converted = lapply(models, function(x) {
			modelWd=file.path(projectPath,modelsDir,x[["wd"]] )
			setwd(modelWd)
			if(!file.exists(x[["model.mdl"]])) {
				stop(paste("File ",file.path(modelWd,x[["model.mdl"]]), "does not exist! Please verify that the test data are correct."))
			}
			x[["model.pharmml"]] = convertToPharmMLAndCopy(x[["model.mdl"]])
			if(!HEADLESS) {
				printMessage(paste("Please, verify that the PharmML file exists:",x[["model.pharmml"]], "\n (You might need refresh the project (select the project in 'Project Explorer' and hit F5-key))."))
				readline("Press <return to continue") 
			}
			x
		});


printMessage("Execute Simulix")
models.simulix = lapply(models.converted, function(model) {
			if(!is.null(model[["simulix.call"]])) {
				modelWd=file.path(projectPath,modelsDir,model[["wd"]] )
				setwd(modelWd)
				model.pharmml = model[["model.pharmml"]]
				print(paste("Running simmulix for", model[["model.mdl"]], "with pharmml", model.pharmml))
				model[["simulix.call"]](model.pharmml);
				if(!HEADLESS) {
					printMessage("Please, verify that Graph was produced")
					readline("Press <return to continue") 
				}
			}
		});


testSummary()
