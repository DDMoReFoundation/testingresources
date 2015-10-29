# PURPOSE: Test TEL estimate
# DESCRIPTION: Runs estimation with Monolix / NONMEM
#   and provides an automated test that each case runs successfully. 
#   NB: DOES NOT test that the answer is *correct*, just that there are no errors
# TODO: 
#   In testing as.xpdb need to find a good way to check expected rows in xpdb vs rawData
# 
# Author: smith_mk
# Date: 13 May 2015
# Revision: 02 Sept 2015
# Tags: xpdb, nonmem, [MODEL_NAME]
# Order: 200
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Generic-[MODEL_NAME]")
projectPath=getwd()

run ({
case<-"[MODEL_DIR]/[MODEL_NAME]"
contextDetail <- "as.xpbd"
context(paste(case,"-",contextDetail))

mdlfile <- getModel(case)
importPromotedResultDir(case, target="NONMEM")
nm <- LoadSOObject(getResult(case, target="NONMEM"))
		
test_that(paste("Converting NONMEM output for",case,"to XPDB"), {
			nm.xpdb <- try(as.xpdb(nm,file.path(dirname(mdlfile),getDataObjects(mdlfile)[[1]]@SOURCE[[1]]$file))) 
			expect_false(class(nm.xpdb)=="try-error", "as.xpdb Doesn't crash with errors")
			expect_is(nm.xpdb,"xpose.data", "Is an Xpose database object") 
			expect_false(is.null(nm.xpdb@Data), "Some data in the merged dataset")
			expect_true(nrow(nm.xpdb@Data)>0, "Some data in the merged dataset")
			# Number of rows in xpdb@Data = nrows in dataset where MDV != 0 
			#rawData <- readDataObj(getDataObjects(mdlfile)[[1]])
			#expect_equal(nrow(nm.xpdb@Data), nrow(subset.data.frame(rawData, (MDV==0)))) 
		}
)
})