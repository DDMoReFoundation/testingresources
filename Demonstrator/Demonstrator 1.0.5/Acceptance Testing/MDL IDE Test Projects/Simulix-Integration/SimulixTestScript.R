#' Executing Simulix against the models:
#' * DelBene
#' * Rocchetti
#' * Simeoni
#' =========================================================================================
#' =========================================================================================

library('mlxR')
library('ggplot2')

if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

projectPath="Simulix-Integration"
modelsDir="models"
setwd(.MDLIDE_WORKSPACE_PATH)
setwd(projectPath)
projectPath=getwd()

HEADLESS=FALSE;

#
# Test Models
#
models <- list(

		list(wd="Claret_2009_oncology_capecitabine_TGI", model.mdl='Claret_2009_oncology_capecitabine_TGI.mdl'
				, simulix.call = function(model.pharmml) {
						d = read.csv('claret_simuldata.csv',na='.')
						p <- c(POP_TS0=0,
							  OMEGA_KD=1,
							  OMEGA_KE=1,
							  POP_LAMBDA=1,
							  OMEGA_LAMBDA=1,
							  OMEGA_TS0=1,
							  POP_KD=1,
							  POP_KE=1,
							  OMEGA_KL=1,
							  POP_KL=1,
							  AERR=1,
							  PERR=1)

						out  <- list( name = c('Y'), time = seq(0,30,by=0.5))
						res <- simulx( model     = model.pharmml,
									   parameter = p,
									   output = out) 

						print(ggplot() + geom_line(data=res$Y, aes(x=time, y=Y)))
				}),
		list(wd="DelBene_2009_oncology_in_vitro_ETA", model.mdl='DelBene_2009_oncology_in_vitro_ETA.mdl'
				, simulix.call = function(model.pharmml) {
					d = read.csv('delbene2009_data.csv',skip=1,na='.')
					head(d)
					N=length(unique(d$ID))
					conc <- d$CONC[!duplicated(d$ID)]
					
					p1 <- c(K1=0.0743, K2=0.0745, LAMBDA0=0.0292, POP_LAMBDA0=0.0292, N0=2147.3, CV=0.1,OMEGA_LAMBDA0=0.001)
					p2 <- list( name     = 'CONC',
							colNames = c('id', 'CONC'),
							value    = cbind(1:N, conc));
					
					out  <- list( name = c('NT','Y'), time = unique(d$TIME[d$EVID!=1]))
					
					res <- simulx( model     = model.pharmml,
							parameter = list(p1,p2),
							output    = out,
							settings  = list(seed=12345));
					
					print(ggplot() + geom_line(data=res$NT, aes(x=time, y=NT, colour=id)) + 
									geom_point(data=res$Y, aes(x=time, y=Y,colour=id)))
				}),
		list(wd="Rocchetti_2013_oncology_TGI_antiangiogenic_combo_ETA", model.mdl='Rocchetti_2013_oncology_TGI_antiangiogenic_combo_ETA.mdl'
				, simulix.call = function(model.pharmml) {
					d = read.csv('rocchetti2013_data.csv',skip=1,na='.')
					head(d)
					
					adm1 <- list( time  = d$TIME[d$EVID==1&d$CMT==1],
							amount = d$AMT[d$EVID==1&d$CMT==1],
							target = 'Q0_A')
					
					adm2 <- list( time   = d$TIME[d$EVID==1&d$CMT==3],
							amount = d$AMT[d$EVID==1&d$CMT==3],
							target = 'Q1_B')
					
					p <- c(EMAX=1, FV1_A=1/0.119, FV1_B=1/2.13, IC50=3.6, IC50COMBO=2.02,
							K1=3.54, K12=141.1, K2=0.221, K21=10.4,
							KA_A=24*log(2)/6.19, KA_B=18.8, KE_A=log(2)/6.05, KE_B=49.2,
							LAMBDA0=0.14, LAMBDA1=0.129, PSI=20, CV=0.1, W0=0.062,POP_LAMBDA0=0.14,OMEGA_LAMBDA0=0.001)
					
					out   <- list( name = c('WTOT','Y'), time = d$TIME[d$EVID!=1])
					
					res <- simulx( model     = model.pharmml,
							parameter = p,
							treatment = list(adm1, adm2),
							output    = out,
							settings  = list(seed=12345))
					
					print(ggplot() + geom_line(data=res$WTOT, aes(x=time, y=WTOT), colour="black") + 
									geom_point(data=res$Y, aes(x=time, y=Y), colour="red"))
				}),
		list(wd="Simeoni_2004_oncology_TGI_ETA", model.mdl='Simeoni_2004_oncology_TGI_ETA.mdl'
				, simulix.call = function(model.pharmml) {
					d = read.csv('simeoni2004_data.csv',skip=1,na='.')
					head(d)
					
					
					p <- c(V1=0.81,  K1=0.968, K2=0.629,  
							K10=0.868*24, K12=0.006*24, K2=0.629, K21=0.0838*24,
							LAMBDA0=0.273, LAMBDA1=0.814, PSI=20, CV=0.1, W0=0.055,POP_LAMBDA0=0.273,OMEGA_LAMBDA0=0.001)
					
					adm2 <- list( time  = d$TIME[d$EVID==1], 
							amount = d$AMT[d$EVID==1], 
							target = 'Q1')
					
					f1 <- list( name='WTOT', time=seq(0,30,by=0.5))
					f2 <- list( name='WTOT', time=seq(0,45,by=0.5))
					y1 <- list( name = 'Y', time = d$TIME[d$EVID!=1&d$ID==1])
					y2 <- list( name = 'Y', time = d$TIME[d$EVID!=1&d$ID==2])
					
					g1 <- list( output = list(y1, f1))
					g2 <- list( treatment = adm2, output = list(y2, f2))
					
					res <- simulx( model     = model.pharmml,
							parameter = p,
							group     = list(g1,g2),
							settings  = list(seed=12345) )
					
					print(ggplot() + geom_line(data=res$WTOT, aes(x=time, y=WTOT, colour=id)) + 
									geom_point(data=res$Y, aes(x=time, y=Y,colour=id)))
				}),
				
		list(wd="Warfarin_ODE", model.mdl='Warfarin-ODE-latest.mdl'
				, simulix.call = function(model.pharmml) {
						d = read.csv('warfarin_conc.csv',na='.')
						p <- c(PPV_CL=1,
							   POP_V=1,
							   POP_KA=1,
							   POP_CL=1,
							   BETA_V_WT=1,
							   PPV_TLAG=1,
							   PPV_V=1,
							   POP_TLAG=1,
							   logtWT=1,
							   BETA_CL_WT=1,
							   PPV_KA=1,
							   RUV_PROP=1,
							   RUV_ADD=1)

						out  <- list( name = c('Y'), time = seq(0,30,by=0.5))
						res <- simulx( model     = model.pharmml,
									   parameter = p,
									   output = out) 

						print(ggplot() + geom_line(data=res$Y, aes(x=time, y=Y)))
				}),
		
		list(wd="Nock_2013_Carboplatin_PK_MONOLIX", model.mdl='Nock_2013_Carboplatin_PK_MONOLIX.mdl'
				, simulix.call = function(model.pharmml) {
					d = read.csv('Carbo_DDMoRe_log2.csv',na='.')
					p <- c(CLCLCR_COV=1,
							THV1=1,
							THV2=1,
							OMCL=1,
							THQ=1,
							logtCLCR=1,
							OMV1=1,
							logtKG=0.7,
							THCL=1,
							V1KG_COV=1,
							SDPROP=1,
							SDADD=1)
					
					out  <- list( name = c('Y'), time = seq(0,30,by=0.5))
					res <- simulx( model     = model.pharmml,
							parameter = p,
							output = out) 
					
					print(ggplot() + geom_line(data=res$Y, aes(x=time, y=Y)))
				})
)

##
#
# Utility functions
##

convertToPharmMLAndCopy <- function(model.mdl = NULL) {
	if(is.null(model.mdl)) {
		stop("No MDL model file was specfied");
	}
	print(paste("Converting ",model.mdl," to PharmML"))
	model.pharmml <- as.PharmML(model.mdl)
	
	if(is.null(model.pharmml)) {
		stop(paste("Couldn't generate pharmml for ", model.mdl))
	}
	
	file.copy(model.pharmml, getwd(), overwrite=TRUE);
	basename(model.pharmml)
}

##
#
# Test Script
##

#
# Converting models to PharmML
#
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

#
# Executing Simulix
#
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


printMessage("DONE")