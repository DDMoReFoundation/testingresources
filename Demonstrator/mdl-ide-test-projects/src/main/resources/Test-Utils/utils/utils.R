#
# Global settings
#
if("testthat" %in% rownames(installed.packages())) {
	library(testthat)
} else {
	warning("testthat library is required for using new testing API. Just manuall test scripts are supported now.")
}


#' What is the mode of the test script execution, 
#' if HEADLESS=TRUE then different assumptions are being made regarding possible user's feedback and reports being created by testthat
if(!exists(".HEADLESS")) {
	.HEADLESS=FALSE
}


#' Build ID
if(!exists(".BUILD_ID")) {
	.BUILD_ID="dev"
}
#' Test Project name
if(!exists(".PROJECT_NAME")) {
	.PROJECT_NAME="dev"
}
#' Test Script name
if(!exists(".SCRIPT_NAME")) {
	.SCRIPT_NAME="dev"
}


#
# Internal variables, don't change!!!
#
#' Cache directory location
if(!exists(".CACHE_DIR")) {
	.CACHE_DIR <- file.path(.MDLIDE_WORKSPACE_PATH, "Test-Utils")
}
#' Name of the file holding results traceback information
CACHE_ENTRY_FILE=".cacheEntry"

#' Creates test that reporter based on the mode of the test harness (headless vs interactive)
createReporter <- function() {
	return(SummaryReporter$new())
}

#'
#' Runs a given code
#' this function ensures that the testthat's reporter is correctly initialized and ended after the script's execution
#' (N.B. this is normally done by testthat, when the tests are invoked via 'test_package' function
#' @param code the closure to execute
#' @param env the environment against which to execute the closure
#' @param reporter the reporter to use
#' 
run <- function(code = NULL, env = parent.frame(), reporter = createReporter()) {
	testthat:::set_reporter(reporter)
	reporter$start_reporter()
	error <- try(eval(code, env))
	reporter$end_reporter()
	if(reporter$failed || class(error)=="try-error") {
		summary <- "FAILURE"
		if(length(reporter$failures)>0) {
			summary <- paste(summary, "There were the following failures:", sep="\n")
			summary <- paste(summary,reporter$failures, sep="\n")
		}
		if(class(error)=="try-error") {
			summary <- paste(summary, "Test failed with error: ", error, sep="\n")
		}
		# ensuring that script execution is marked as failed by ATH
		stop(summary)
	}
}

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
                model[["xpose"]] = as.xpdb(so,file.path(modelFileLocation,dataObj@SOURCE[[1]]$file))
            } else {
                errorMsg <- paste("There were errors when executing model",model[["modelFile"]],"skipping Xpose database creation")
                printMessage(errorMsg)
                recordError(errorMsg)
            }
            model
        })
}


#' Runs estimation with given target
#' @param list of MDL files relative to project directory
#' 
#' @return list of lists with elements: 
#' 'so' - standard output object, 
#' 'modelFile' - model file used, (relative to the mdlIdeProjectPath)
estimateModelsWith <- function(models, target, mdlIdeProjectPath = projectPath, targetArgs="") {
    lapply(models, function(modelFile) {
                setwd(mdlIdeProjectPath)
                printMessage(paste("Running ",target," with ", modelFile))
                resultDir = .resultDir(paste0(basename(modelFile),"-",target));
                so <- tryCatch( {
                    estimate(modelFile, target=target, addargs=targetArgs, subfolder=resultDir);
                }, error = function(err) {
                    warning(err)
                    recordError(err)
                    NULL
                })
                warnings()
                model <- list("modelFile" = modelFile, "so" = so, "resultDir" = resultDir)
                return(model)
            })
}

#' Verifies estimation results. Function stops with an error message if verfication fails.
#' @param so - standard output object from an execution
#' @return true on successful execution
verifyEstimate = function (so) {
    assert(!is.null(so),"SO object was null.",!.HEADLESS) &&
    assert(is.null(so@TaskInformation$Messages$Errors),paste0("There were error messages set on the SO ", so@TaskInformation$Messages$Errors),!.HEADLESS) &&
    assert(!is.null(so@Estimation@PopulationEstimates$MLE$data),"MLE values were not populated.", !.HEADLESS) &&
    assert(!(is.null(so@Estimation@Likelihood$Deviance)&&is.null(so@Estimation@Likelihood$LogLikelihood)),"Log-Likelihood element was not set.", !.HEADLESS)
}

#' Asserts that a given condition is met, if not it will print an error message and return FALSE
#' or it will stop the execution with a given message.
#' @param condition - expression which should eval to true
#' @param message - a message that will be used as error message if the condition is not met
#' @return true on successful execution, false if the the condition is not true
assert = function (condition, message, stop=TRUE) {
    if(!condition) {
        errorMsg = paste0("Assertion failed: ", message)
        recordError(errorMsg)
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



#' Returns all MDL files found in mdlIdeProjectPath's subdirectories listed in modelsDirNames
#' follows the convention <mdlIdeProjectPath>\<modelsDirName>\<MODEL_FILE>
#' The paths are relative to the mdlIdeProjectPath
.getMDLFilesFromModelDirectoryFlat <- function(mdlIdeProjectPath = projectPath, modelsDirNames = list("models")) {
    unlist(lapply(modelsDirNames, function(modelsDirName) {
                modelsDir <- file.path(mdlIdeProjectPath, modelsDirName)
                cat(paste0("Looking for models in ",modelsDir,"\n"))
                files = dir(modelsDir, pattern=".*\\.mdl$")
                unlist(lapply(files, function(x) {
                                    file.path(modelsDirName, x)
                                }))
            }))
    
}

#' Generates a result directory name
.resultDir <- function(basename) {
    paste0(basename,"_",format(Sys.time(),"%H%M%S"),".out")
}

#'
#' Performs test script initialization
#' @param project name
#'
initialize <- function(projectName) {
	setwd(.MDLIDE_WORKSPACE_PATH)
	setwd(projectName)
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

##############################################################
#' createSubDirectory
#'
#' Create a sub-directory of the currently set projectPath.
#'
#' @param the name of the sub-directory to create
#' @param the absolute path of the project directory
createSubDirectory <- function(name, projectPath) {
	subDir<-file.path(projectPath,name)
	dir.create(subDir)
	subDir
}

.errors <- list()
#################################################################
#' resetErrors
#'
#'Resets errors list
#'
resetErrors <- function() {
    .errors <<- list()
}

##################################################################
#' finalStatus
#' prints final status or results in error with all errors recorded
#'
testSummary <- function() {
    if(length(.errors)>0) {
        stop(paste(.errors, collapse="\n"))
    } else {
        printMessage("SUCCESS")
    }
}
##################################################################
#' recordError
#'
#' records error message
#'
recordError <- function(errorMsg) {
    .errors <<- c(.errors, errorMsg)
}

#'
#' Resolves model file path from a modelPath.
#'
#' @usage getModel("models/UseCase1")
#'
#' @param modelPath a path to a model within project (without extension)
#' @param projectPath the path to the project against which to resolve model file name
#'
getModel <- function(modelPath, projectPath = getwd()) {
	file.path(projectPath, paste0(modelPath,".mdl"))
}

#'
#' Generates results directory for given modelPath and target tool.
#'
#' Note, this function encapsulates the naming convention of the results directory 
#' and ensures that the test harness is able to attach semantics to created resources by the test scripts
#'
#' @usage getResultDir("models/UseCase1", "NONMEM")
#'
#' @param modelPath a path to a model within project (without extension)
#' @param target the target tool of which the result files will be stored in the directory
#' @param projectPath the path to the project against which to resolve model file name
#' @param id optional identifier that can be used to uniquely name the directory
#'
getResultDir <- function(modelPath, target, projectPath = getwd(), id = "") {
	modelPath <- getModel(modelPath, projectPath)
	paste0(modelPath, "-", target, ifelse(id=="", "", paste0("-",id)))
}

#'
#' Gets SO file location for given modelPath
#' @param see getResultDir for parameters
#'
getResult <- function (modelPath, target, projectPath = getwd(), id = "") {
	modelFilePath <- getModel(modelPath, projectPath)
	file.path(getResultDir(modelPath, target, projectPath, id), paste0(file_path_sans_ext(basename(modelFilePath)), ".SO.xml"))
}

#'
#' Copies from directory contents to 'to' directory
#'
copy.dir <- function(from, to) {
	if (!file.exists(to)) {
		dir.create(to)
	}
	all.regular.files <- list.files(from, pattern=".*")
	files.to.copy <- paste0(from, "/", all.regular.files) # Turn the filenames into full paths
	file.copy(files.to.copy, to, recursive=TRUE)
}


#
# Promoting/caching results mechanism.
#

#'
#' Promotes a given results directory and makes it available to other test scripts for import
#' @param modelPath - the path to model file with which to associate the result (relative to project root)
#' @param resultDir - the results directory
#' @param target - the target that produced the result (e.g. NONMEM, MONOLIX, Bootstrap, etc.)
#' @return directory where the promoted result directory has been copied to
promoteResult <- function(modelPath, resultDir, target) {
	targetDir <- .getPromotedResultDirectory(modelPath, target)
	if(file.exists(targetDir)) {
		unlink(targetDir, recursive=TRUE)
	}
	copy.dir(resultDir, targetDir)
	.createPromotionRecord(modelPath, targetDir)
	return(targetDir)
}

#'
#' Imports promoted result. If the directory where the results should be imported already exist this function silently skips the copy operation.
#'
#' @param modelPath - the path to the model file (relative to project root)
#' @param target - the target tool that produced the result (e.g. NONMEM)
#' @param projectPath - the project root where the result should be imported to
#' @return the directory where the results have been imported
#'
#' @throw function stops if the results directory for given model don't exist 
importPromotedResultDir <- function(modelPath, target, projectPath = getwd(), id = "") {
	resultDir <- getResultDir(modelPath, target, projectPath, id)
	if(file.exists(resultDir)) {
		#The promoted result already exists in local project workspace
		return(resultDir)
	}
	promoted <- .getPromotedResultDirectory(modelPath, target)
	if(!file.exists(promoted)) {
		stop(paste("There is no result directory for", modelPath, "and", target,
						".\nHas the",modelPath,"been executed and its results been 'promoted'?"))
	}
	copy.dir(promoted, resultDir)
	return(resultDir)
}

#'
#' Internal
#' gets the location of the result directory within cache directory
#'
.getPromotedResultDirectory <- function(modelPath, target) {
	getResultDir(modelPath, target, .CACHE_DIR)
}

#'
#' Internal
#' Creates a JSON formatted file that holds traceability information associated with results being promoted
#'
.createPromotionRecord <- function(modelPath, targetDir) {
	metadata = list("buildId" = .BUILD_ID, "modelPath" = modelPath,  "scriptName" = .SCRIPT_NAME, "projectName" = .PROJECT_NAME, "timestamp" = format(Sys.time(),"%H%M%S"))
	fileConn<-file(file.path(targetDir, CACHE_ENTRY_FILE))
	writeLines(toJSON(metadata), fileConn)
	close(fileConn)
}

