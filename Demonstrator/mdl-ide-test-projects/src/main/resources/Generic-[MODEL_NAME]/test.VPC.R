# PURPOSE: Test TEL VPC
# DESCRIPTION: Runs VPC with PsN
#   and provides an automated test that each case runs successfully. 
#   NB: DOES NOT test that the answer is *correct*, just that there are no errors
# TODO: 
# 
# Author: smith_mk
# Date: 14 August 2015
#
# Tags: execution, psn, vpc, [MODEL_NAME]
# Order: 300
###############################################################################

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Generic-[MODEL_NAME]")
projectPath=getwd()

run ({
case<-"[MODEL_DIR]/[MODEL_NAME]"
contextDetail <- "VPC"
context(paste(case,"-",contextDetail))
mdlfile <- getModel(case)

importPromotedResultDir(case, target="NONMEM")
nm <- try(LoadSOObject(getResult(case,"NONMEM")))

test_that(paste("VPC",case), {
			target <- "VPC"
			resultDir <- getResultDir(case,target)
			resultDirName <- basename(resultDir)
			vpcFiles <- try(VPC.PsN(mdlfile, 
							samples=100, seed=123456, 
							subfolder=resultDirName, plot=FALSE)) 
			expect_false(class(vpcFiles)=="try-error", "VPC.PsN Doesn't crash")
			myVPCPlot <- xpose.VPC(vpc.info=vpcFiles$vpc.info,vpctab=vpcFiles$vpctab,main="VPC warfarin")
			expect_is(myVPCPlot,"trellis", "xpose.VPC Produces a plot")
		}
)
})