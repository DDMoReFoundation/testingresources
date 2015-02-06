# TODO: Script Testing the Simulix execution
# 
# Author: mrogalski
###############################################################################

if(!exists("mdlEditorHome")||is.null(mdlEditorHome)) {
	mdlEditorHome= getwd();
}
projectPath="workspace/Monolix-Integration";
setwd(mdlEditorHome)
setwd(projectPath)
source("utils/utils.R")
projectPath = getwd();

model = "DelBene_2009_oncology_in_vitro_ETA_4.02/DelBene_2009_oncology_in_vitro_ETA.mdl"
printMessage(model)
estSO = estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}
readline("Press <return to continue") 

setwd(mdlEditorHome)
setwd(projectLoc)
model = "Nock_2013_Carboplatin_PK_MONOLIX_4.02/Nock_2013_Carboplatin_PK_MONOLIX.mdl"
printMessage(model)
estSO=estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}
readline("Press <return to continue") 

setwd(mdlEditorHome)
setwd(projectLoc)
model = "Rocchetti_2013_oncology_TGI_antiangiogenic_combo_ETA_4.02/Rocchetti_2013_oncology_TGI_antiangiogenic_combo_ETA.mdl"
printMessage(model)
estSO=estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}
readline("Press <return to continue") 

setwd(mdlEditorHome)
setwd(projectLoc)
model = "Simeoni_2004_oncology_TGI_ETA_4.02/Simeoni_2004_oncology_TGI_ETA.mdl"
printMessage(model)
estSO=estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}
readline("Press <return to continue") 


printMessage("DONE")