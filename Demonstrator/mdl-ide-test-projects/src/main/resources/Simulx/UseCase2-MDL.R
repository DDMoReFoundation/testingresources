if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Simulx")
projectPath=getwd()

pharmML.model <- as.PharmML(file.path(projectPath,"models/UseCase2.mdl"))
#-------------------------------------

library("gridExtra")

#-------------------------------------

mlxtran.model <- pharmml2mlxtran(pharmML.model)

adm <- list( time   = 4, amount = 100)

p <- c(POP_V=8.38,
       BETA_V_WT=1,
       POP_KA=1.31,
       POP_CL=0.13,
       BETA_CL_WT=0.75,
       POP_TLAG=0.82,
       DT_pop=0,
       PPV_V=0.12,
       PPV_KA=0.68,
       PPV_CL=0.25,
       PPV_TLAG=0.13,
       omega_DT=0,
       r_V_CL=0.47,
       RUV_ADD=0,
       RUV_PROP=0.17,
       WT=60,
       D=100,
       DT=5)

ind <- list( name = c('TLAG','KA','V','CL'))

y   <- list( name = c('Y'), time = seq(2,to=50,by=2))

g <- list( size = 4, level = 'individual',  treatment = adm);

res <- simulx( model     = pharmML.model,
               parameter = p,
               output    = list(y),
               group     = g);

print(res$Y)



