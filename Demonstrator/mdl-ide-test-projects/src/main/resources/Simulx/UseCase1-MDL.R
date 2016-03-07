if(!exists(".MDLIDE_WORKSPACE_PATH") || is.null(.MDLIDE_WORKSPACE_PATH)) {
	stop(".MDLIDE_WORKSPACE_PATH variable should be set to the path of the MDL IDE workspace")
}
source(file.path(.MDLIDE_WORKSPACE_PATH,"Test-Utils/utils/utils.R"));

initialize("Simulx")
projectPath=getwd()

pharmML.model <- as.PharmML(file.path(projectPath,"models/UseCase1.mdl"))

#-------------------------------------
library("gridExtra")

#-------------------------------------
#pharmML.model <- "pharmML/UseCase1.xml"

mlxtran.model <- pharmml2mlxtran(pharmML.model)

adm <- list( time   = 4, amount = 100)

p <- c(POP_V=16.21,
       BETA_V_WT=1,
       POP_KA=1.61,
       POP_CL=0.27,
       BETA_CL_WT=0.75,
       POP_TLAG=0.9,
       PPV_V=0.13,
       PPV_KA=0.84,
       PPV_CL=0.27,
       PPV_TLAG=0.29,
       r_V_CL=0.23,
       RUV_ADD=0.17,
       RUV_PROP=0.07,
       logtWT=0.1
       )

ind <- list( name = c('TLAG','KA','V','CL'))
f   <- list( name = c('CC'), time = seq(0,to=60,by=1))
y   <- list( name = c('Y'), time = seq(2,to=50,by=2))

g <- list( size = 4, level = 'individual',  treatment = adm);

res <- simulx( model     = pharmML.model,
               parameter = p,
               output    = list(f, y),
               group     = g);

print(res$Y)



