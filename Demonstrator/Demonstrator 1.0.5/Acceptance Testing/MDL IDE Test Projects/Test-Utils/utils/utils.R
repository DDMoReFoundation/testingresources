#
# Global settings
#

#' Should user NOT be propted to check outputs?
HEADLESS=TRUE;


##########################################################################################
# Common Bulk Modelling Tasks
##########################################################################################

#' Validates Estimation results
#' @param list of lists with elements: 
#' 'so' - standard output object, 
#' 'modelFile' - model file used, 
#' @return input lists with additional 'valid' flag
validateExecutions <- function(models.SO) {
	lapply(models.SO, function(modelWithSO) {
				setwd(projectPath)
				so = modelWithSO[["so"]]
				if(length(so@TaskInformation$Messages$Errors)>0) {
					printMessage(paste("There were errors when executing model",modelWithSO[["modelFile"]]))
					print(so@TaskInformation$Messages$Errors)
					modelWithSO[["valid"]] = FALSE
				}
				modelWithSO[["valid"]] = TRUE
				modelWithSO
			})
}

#' Creates xpose databases for valid SOs on the list
#' @param list of lists with elements: 
#' 'so' - standard output object, 
#' 'modelFile' - model file used, 
#' 'valid' - flag indicating if a the execution was successful
#' @return input lists with additional 'xpose' element
#' 
createXposeDatabases <- function(models.validated) {
	lapply(models.validated, function(model) {
			setwd(projectPath)
			so = model[["so"]]
			valid = model[["valid"]]
			if(valid) {
				printMessage(paste("Creating Xpose database for ",model[["modelFile"]]))
				dataObj = getDataObjects(model[["modelFile"]])[[1]]
				modelFileLocation = parent.folder(model[["modelFile"]])
				model[["xpose"]] = as.xpdb(so,file.path(modelFileLocation,dataObj@SOURCE$file))
			} else {
				printMessage(paste("There were errors when executing model",model[["modelFile"]],"skipping Xpose database creation"))
			}
		})
}


#' Runs estimation with given target
#' @param list of MDL files relative to project directory
#' 
#' @return list of lists with elements: 
#' 'so' - standard output object, 
#' 'modelFile' - model file used, 
estimateModelsWith <- function(models, target) {
	lapply(models, function(modelFile) {
				setwd(projectPath)
				modelFilePath = paste(modelsDir,modelFile, sep="/");
				printMessage(paste("Running",target,"with ", modelFilePath))
				so <- estimate(modelFilePath, target=target, subfolder=.resultDir(target));
				warnings()
				if(!HEADLESS) {
					printMessage("Please, verify that the execution did not fail")
					readline("Press <return to continue") 
				}
				model <- list("modelFile" = modelFilePath, "so" = so)
				return(model)
			})
}



#'
#' Prints a formatted message
printMessage <- function(message) {
	print(paste(replicate(60, "#"), collapse = ""))
	print(message)
	print(paste(replicate(60, "#"), collapse = ""))
}



#' Returns all MDL files found in the subdirectory of the given directory
#' follows the convention <modelsRootDir>\<MODEL_DIR>\<MODEL_FILE>
#' The paths are relative to the modelsRootDir
.getMDLFilesFromModelDirectory <- function(modelsRootDir) {
	modelDirs = dir(modelsRootDir)
	print(paste("Looking for models in ",modelsRootDir))
	lapply(modelDirs,function(modelDir) {
				file <- grep(".*\\.mdl",dir(file.path(modelsRootDir,modelDir)),fixed=FALSE,invert=FALSE,value=TRUE)
				if (length(file)==1){
					return(file.path(modelDir,file[1]));
				} else if(length(file)>1) {
					stop(paste("More then one mdl file found in",modelDir,"! Fix the issue!"))
				}
			})
}

#' Generates a result directory name
.resultDir <- function(basename) {
	paste0(basename,"_",format(Sys.time(),"%H%M%S"),".out")
}

##############################################################
#' parent.folder
#'
#' Derive the absolute path to a file (or folder), takes its parent,
#' and returns the path to this parent folder.
#'
#' Note that the file/folder must exist.
#'
#' @param f file/folder for which to find its parent
#' @param the absolute path to the parent folder of the input file/folder
parent.folder <- function(f) {
	dirname(file_path_as_absolute(f))
}