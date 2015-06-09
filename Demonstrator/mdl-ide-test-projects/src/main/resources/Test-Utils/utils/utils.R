#
# Global settings
#

#' Should user NOT be propted to check outputs?
HEADLESS=TRUE;


##########################################################################################
# Common Bulk Modelling Tasks
##########################################################################################

#' Verifies Estimation results
#' @param list of lists with elements: 
#' 'so' - standard output object, 
#' 'modelFile' - model file used, 
#' @return input lists with additional 'valid' flag
verifyExecutions <- function(models.SO) {
	lapply(models.SO, function(modelWithSO) {
				setwd(projectPath)
				so = modelWithSO[["so"]]
				modelWithSO[["valid"]] = verifyEstimate(so)
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
			model
		})
}


#' Runs estimation with given target
#' @param list of MDL files relative to project directory
#' 
#' @return list of lists with elements: 
#' 'so' - standard output object, 
#' 'modelFile' - model file used, 
estimateModelsWith <- function(models, target, mdlIdeProjectPath = projectPath, modelsSubDirectory = modelsDir, targetArgs=NULL) {
	lapply(models, function(modelFile) {
				setwd(mdlIdeProjectPath)
				modelFilePath = file.path(modelsSubDirectory,modelFile);
				printMessage(paste("Running ",target," with ", modelFilePath))
				resultDir = .resultDir(paste0(basename(modelFile),"-",target));
				so <- tryCatch( {
					estimate(modelFilePath, target=target, addargs=targetArgs, subfolder=resultDir);
				}, error = function(err) {
					NULL
				})
				warnings()
				model <- list("modelFile" = modelFilePath, "so" = so, "resultDir" = resultDir)
				return(model)
			})
}

#' Verifies estimation results. Function stops with an error message if verfication fails.
#' @param so - standard output object from an execution
#' @param outputDirectory - a directory where the outputs reside
#' @return true on successful execution
verifyEstimate = function (so, outputDirectory=NULL) {
	assert(!is.null(so),"SO object was null.",!HEADLESS) &&
	assert(!is.null(outputDirectory) && is.null(list.files(outputDirectory,pattern="\\.SO.xml$")),"SO xml was not found.",!HEADLESS) &&
	assert(!is.null(so@TaskInformation$Messages$Errors),message(so@TaskInformation$Messages$Errors),!HEADLESS) &&
	assert(is.null(so@Estimation@PopulationEstimates$MLE$data),"MLE values were not populated.", !HEADLESS) &&
	assert(is.null(so@Estimation@Likelihood$Deviance),"Log-Likelihood element was not set.", !HEADLESS)
}

#' Asserts that a given condition is met, if not it will print an error message and return FALSE
#' or it will stop the execution with a given message.
#' @param condition - expression which should eval to true
#' @param message - a message that will be used as error message if the condition is not met
#' @return true on successful execution, false if the the condition is not true
assert = function (condition, message, stop=TRUE) {
	if(condition) {
		errorMsg = paste0("Assertion failed: ", message)
		if(stop) {
			stop(errorMsg)
		} else {
			printMessage(errorMsg)
		}
	}
	return(condition)
}

#'
#' Prints a formatted message
printMessage <- function(message) {
	cat(paste(replicate(60, "#"), collapse = ""))
	cat("\n")
	print(message)
	cat(paste(replicate(60, "#"), collapse = ""))
	cat("\n")
}



#' Returns all MDL files found in the subdirectory of the given directory
#' follows the convention <modelsRootDir>\<MODEL_FILE>
#' The paths are relative to the modelsRootDir
.getMDLFilesFromModelDirectoryFlat <- function(modelsRootDir) {
	files = dir(modelsRootDir, pattern=".*\\.mdl$")
	cat(paste0("Looking for models in ",modelsRootDir, "\n"))
	files
}

#' Returns all MDL files found in the subdirectory of the given directory
#' follows the convention <modelsRootDir>\<MODEL_DIR>\<MODEL_FILE>
#' The paths are relative to the modelsRootDir
.getMDLFilesFromModelDirectory <- function(modelsRootDir) {
	modelDirs = dir(modelsRootDir)
	cat(paste0("Looking for models in ",modelsRootDir,"\n"))
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