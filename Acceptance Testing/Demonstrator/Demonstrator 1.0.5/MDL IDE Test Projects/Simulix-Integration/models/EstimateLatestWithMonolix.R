# TODO: Script Testing the Simulix execution
# 
# Author: mrogalski
###############################################################################

#if(is.null(projectLoc)) {
#	stop("You must call this script in scope of a project so all models are correctly resolved")
#}
#
setwd(projectLoc)

print("#######################################")
print("START - Estimating models with Monolix")
print("#######################################")
model = "DelBene_2009_oncology_in_vitro/DelBene_2009_oncology_in_vitro.mdl"
print(model)
estSO = estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}

setwd(projectLoc)
model = "Nock_2013_Carboplatin_PK/Nock_2013_Carboplatin_PK.mdl"
print(model)
estSO=estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}

setwd(projectLoc)
model = "Rocchetti_2013_oncology_TGI_antiangiogenic_combo/Rocchetti_2013_oncology_TGI_antiangiogenic_combo.mdl"
print(model)
estSO=estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}

setwd(projectLoc)
model = "Simeoni_2004_oncology_TGI/Simeoni_2004_oncology_TGI.mdl"
print(model)
estSO=estimate(model, target = "MONOLIX")
if(is.null(estSO)) {
	stop(paste("Failed to execute model", model));
}


print("######################################")
print("DONE - Estimating models with Monolix")
print("######################################")