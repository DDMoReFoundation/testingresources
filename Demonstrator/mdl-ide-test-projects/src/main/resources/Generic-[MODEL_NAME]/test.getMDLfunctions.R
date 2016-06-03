# PURPOSE: Test TEL MDL reading functions
# DESCRIPTION: Reads MDL file and checks that objects are of correct type and structure
# TODO: 
# 
# Author: smith_mk
# Date: 03 Aug 2015
# Revisions: 
#
# Tags: mdl, [MODEL_NAME]
# Order: 1
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Generic-[MODEL_NAME]")
projectPath=getwd()

run ({
case<-"[MODEL_DIR]/[MODEL_NAME]"
contextDetail <- "MDL Functions"
context(paste(case,"-",contextDetail))
mdlfile <- getModel(case)

# temporary fix for data file being relative to model file
setwd(dirname(mdlfile))


## getMDLObjects
test_that(paste("Get MDL objects for",case), {
			myMDLObj <- try(getMDLObjects(mdlfile))
			
			expect_false(class(myMDLObj) == "try-error", "getMDLObjects doesn't crash with errors")
			
			expect_is(myMDLObj, "list", "Should be a list")
			
			expect_equal(length(myMDLObj),4, "Should be 4 items")
			expectedMDLObjects <- c("dataObj", "parObj", "mdlObj", "taskObj") 
			readMDLObjects <- unlist(lapply(myMDLObj,class))
			names(readMDLObjects) <- NULL
			expect_identical(readMDLObjects, expectedMDLObjects, "Should have dataObj, parObj, mdlObj and taskObj classes") 
	}
)

## getDataObject
test_that(paste("Get Data Object for",case), {
			myDataObj <- try(getDataObjects(mdlfile))
			names(myDataObj) <- NULL
			
			expect_false(class(myDataObj) == "try-error", "getDataObjects doesn't crash with errors")
			expect_is(myDataObj, "list", "DataObj Should be a list")
			expect_equal(length(myDataObj), 1, "Should be 1 item")

			## Extract first object
			myDataObj <- myDataObj[[1]]
			expect_is(myDataObj, "dataObj", "Should be of class dataObj")

			expectedDataBlocks <- c("SOURCE", "DECLARED_VARIABLES", "DATA_INPUT_VARIABLES", "DATA_DERIVED_VARIABLES")
			expectedDataBlocks <- c(expectedDataBlocks, "name")
			readDataBlocks <- slotNames(myDataObj)
			expect_equal(readDataBlocks, expectedDataBlocks, "Expected slots are present")
				
			## Read data from file
			myData <- readDataObj(myDataObj)
			expect_is(myData, "data.frame")
			expect_false(is.null(myData), "Expect some content")
			expectedDataColumns <- names(myDataObj@DATA_INPUT_VARIABLES)
			readDataColumns <- names(myData)
			expect_equal(readDataColumns, expectedDataColumns, "Check column names")
		}
)

## getParameterObject
test_that(paste("Get Parameter Object for",case), {
			myParObj <- try(getParameterObjects(mdlfile))
			names(myParObj) <- NULL
			expect_false(class(myParObj) == "try-error", "getParameterObjects doesn't crash with errors")
			expect_is(myParObj, "list", "Should be a list")
			expect_equal(length(myParObj), 1, "Should be 1 item")
			
			## Extract first object
			myParObj <- myParObj[[1]]
			expect_is(myParObj, "parObj", "Should be of class parObj")
			
			expectedParBlocks <- c("DECLARED_VARIABLES", "STRUCTURAL", "VARIABILITY")
			expectedParBlocks <- c(expectedParBlocks, "name")
			readParBlocks <- slotNames(myParObj)
			expect_equal(readParBlocks, expectedParBlocks, "Expected slots are present")
		}
)

## getModelObject
test_that(paste("Get Model Object for",case), {
			myModelObj <- try(getModelObjects(mdlfile))
			names(myModelObj) <- NULL
			expect_false(class(myModelObj) == "try-error", "getModelObjects doesn't crash with errors")
			expect_is(myModelObj, "list", "Should be a list")
			expect_equal(length(myModelObj), 1, "Should be 1 item")
			
			## Extract first object
			myModelObj <- myModelObj[[1]]
			expect_is(myModelObj, "mdlObj", "Should be of class mdlObj")

			expectedModelBlocks <- c("IDV",                       "COVARIATES",               
									 "VARIABILITY_LEVELS",        "STRUCTURAL_PARAMETERS",    
		 						 	 "VARIABILITY_PARAMETERS",    "RANDOM_VARIABLE_DEFINITION",
		 						 	 "INDIVIDUAL_VARIABLES",      "MODEL_PREDICTION",         
		 						 	 "OBSERVATION",               "GROUP_VARIABLES")
			expectedModelBlocks <- c(expectedModelBlocks, "name")
			readModelBlocks <- slotNames(myModelObj)
			expect_equal(readModelBlocks, expectedModelBlocks, "Expected slots are present")
		}
)

## getTaskPropertiesObjects
test_that(paste("Get Task Properties Object for",case), {
			myTaskObj <- try(getTaskPropertiesObjects(mdlfile))
			names(myTaskObj) <- NULL
			expect_false(class(myTaskObj) == "try-error", "getTaskPropertiesObjects Doesn't crash with errors")
			expect_is(myTaskObj, "list", "Should be a list")
			expect_equal(length(myTaskObj), 1, "Should be 1 item")
			
			## Extract first object
			myTaskObj <- myTaskObj[[1]]
			expect_is(myTaskObj, "taskObj", "Should be of class taskObj")
			
			expectedTaskBlocks <- c("ESTIMATE", "SIMULATE", "EVALUATE")
			expectedTaskBlocks <- c(expectedTaskBlocks, "name")
			readTaskBlocks <- slotNames(myTaskObj)
			expect_equal(readTaskBlocks, expectedTaskBlocks, "Expected slots are present")
			
		}
)
})
