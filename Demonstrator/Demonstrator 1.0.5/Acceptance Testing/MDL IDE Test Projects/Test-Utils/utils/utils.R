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

#'
#' Prepends the directory name with 'workspace/' if the parent is named 'workspace'
#' this is a naive way of detecting if the tests are run in MDL IDE from SEE or in dev environment
.prependWithWorkspaceIfNeeded <- function(mdlEditorHome, directory) {
	name = basename(mdlEditorHome)
	if (name=="workspace"){
		return(paste("workspace",directory,sep='/'))
	}
	directory
}

#' Generates a result directory name
.resultDir <- function(basename) {
	paste0(basename,"_",format(Sys.time(),"%H%M%S"),".out")
}