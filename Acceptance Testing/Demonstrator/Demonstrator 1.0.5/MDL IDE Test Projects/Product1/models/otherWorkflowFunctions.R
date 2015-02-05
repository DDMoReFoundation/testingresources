## ----defineFunctions-------------------------------------------------------

## ---getNMBlocks: identifies the various blocks of a NONMEM control stream
getNMBlocks<-function(RNMImportObject){
  Raw<-RNMImportObject[[1]]
  blocks<-grep("^\\$",Raw)
  nextBlock<-c(blocks[-1],length(Raw))
  ## Drop commented out lines
  ## blocks<-blocks[-grep("[;]",blocks)]
  ### Get first "word" to determine order
  blocks2<-sub( " +.*", "", Raw[blocks] )   
  blocks3<-sub("$","",blocks2, fixed=T)
  data.frame(Blocks=blocks2,Search=blocks3,firstRow=blocks,nextBlockRow=nextBlock)
}

## ---getNMDataObjects: Reads the $DATA and $INPUT records and parses them
getNMDataObjects<-function(RNMImportObject){
  Raw<-RNMImportObject[[1]]
  Parsed<-RNMImportObject[[4]][[1]]
  
  blockInfo<-getNMBlocks(RNMImportObject)
  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="DATA",c("firstRow","nextBlockRow")])
  rawDataRows<-Raw[rows[1]:(rows[2]-1)]

  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="INPUT",c("firstRow","nextBlockRow")])
  rawInputRows<-Raw[rows[1]:(rows[2]-1)]

  RAW<-c(rawDataRows,rawInputRows)
  if(length(grep("^\\;",RAW))>0){
    RAW<-RAW[-grep("^\\;",RAW)]
  }
  
  list(RAW=RAW,
       HEADER=Parsed$Input,
       FILE=Parsed$Data)
}

## ---getNMParameterObjects: Reads the $THETA, $OMEGA, $SIGMA records and parses them
getNMParameterObjects<-function(RNMImportObject){
  Raw<-RNMImportObject[[1]]
  Parsed<-RNMImportObject[[4]][[1]]
  
  blockInfo<-getNMBlocks(RNMImportObject)
  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="THETA",c("firstRow","nextBlockRow")])
  rawThetaRows<-Raw[rows[1]:(rows[2]-1)]
  
  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="OMEGA",c("firstRow","nextBlockRow")])
  rawOmegaRows<-Raw[rows[1]:(rows[2]-1)]
  
  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="SIGMA",c("firstRow","nextBlockRow")])
  rawSigmaRows<-Raw[rows[1]:(rows[2]-1)]

  RAW<-c(rawThetaRows,rawOmegaRows,rawSigmaRows)
  if(length(grep("^\\;",RAW))>0){
    RAW<-RAW[-grep("^\\;",RAW)]
  }
  
  list(RAW=RAW,
    STRUCTURAL=Parsed$Theta,
       VARIABILITY=list(IIV=Parsed$Omega,
                        RUV=Parsed$Sigma))
}

## ---getNMTaskProperties: Reads the $EST, $COV, $TAB records and parses them 
getNMTaskPropertiesObjects<-function(RNMImportObject){
  Raw<-RNMImportObject[[1]]
  Parsed<-RNMImportObject[[4]][[1]]
  
  blockInfo<-getNMBlocks(RNMImportObject)
  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="EST",c("firstRow","nextBlockRow")])
  rawEstRows<-Raw[rows[1]:(rows[2]-1)]
  
  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="COV",c("firstRow","nextBlockRow")])
  rawCovRows<-Raw[rows[1]:(rows[2]-1)]

  rows<-unlist(blockInfo[as.character(blockInfo$Search)=="TAB",c("firstRow","nextBlockRow")])
  rawTableRows<-Raw[rows[1]:(rows[2]-1)]
  
  RAW<-c(rawEstRows,rawCovRows)
  if(length(grep("^\\;",RAW))>0){
    RAW<-RAW[-grep("^\\;",RAW)]
  }
  
  list(RAW=RAW,
    TARGET_CODE=list(Parsed$Estimates, 
                        Parsed$Cov,
                     Parsed$Tables))
}

## ---getNMObjects: Retrieves Data, Parameters, Task Properties from a NONMEM control file
getNMObjects<-function(RNMImportObject,what=c("Data","Parameters","TaskProperties","All")){
  ## TO BE WRITTEN
}

## --basicGOF.Xpose: Finds the run number from sdtab, creates an xpdb and runs basic GOF plots
basicGOF.Xpose<-function(){
  ## ----setupRunnoforXpose--------------------------------------------------
runno <- as.numeric(gsub("[a-z]", "", list.files(pattern="^sdtab")[1]))


## ----createXpdb----------------------------------------------------------
base.xpdb<-xpose.data(runno)
#save(base.xpdb, file="Xpose database.RData")

## ----xposeGOF------------------------------------------------------------
print(dv.vs.pred.ipred(base.xpdb))
print(pred.vs.idv(base.xpdb))
print(ipred.vs.idv(base.xpdb))
print(cwres.vs.idv(base.xpdb))
print(cwres.vs.pred(base.xpdb))
print(ranpar.hist(base.xpdb))
print(parm.splom(base.xpdb))
print(parm.vs.cov(base.xpdb))
print(ind.plots(base.xpdb, layout=c(4,4)))
# etc. etc.
}

### ----estimate.NM: Estimates parameters using nmfe72
estimate.NM<-function(modelfile=NULL,nonmem.exe="c:\\pkpd\\bin\\nonmem-7.2.bat",modelExtension=".mod",reportExtension=".lst",addargs="",cleanup=T)
  {
  command<-paste(nonmem.exe,paste(modelfile,modelExtension,sep=""),paste(modelfile,reportExtension,sep=""))
  cat(paste(command,"\n"))
  if(.Platform$OS.type == "windows")args<-list(command,intern=F,minimized=F,invisible=F,show.output.on.console=T,wait=T)
  if(.Platform$OS.type != "windows")args<-list(command,wait=T)
  do.call(system,args)
  if(cleanup)cleanup()
}

### ----execute.PsN: Estimates parameters using PsN Execute
execute.PsN<-function(modelfile=NULL,command="c:\\pkpd\\bin\\execute-3.5.4",addargs="",cleanup=T,...){
  command<-paste(command,shQuote(paste(modelfile,".mod",sep="")),addargs)
  cat(paste(command,"\n"))
  if(.Platform$OS.type == "windows")args<-list(command,intern=F,minimized=F,invisible=F,show.output.on.console=T,wait=T)
  if(.Platform$OS.type != "windows")args<-list(command,wait=T)
  do.call(system,args)
  if(cleanup)cleanup()
}

### ----VPC: Performs VPC for an existing model
VPC.PsN<-function(command="c:\\pkpd\\bin\\vpc-3.5.4.bat ",modelfile,nsamp,seed,addargs,cleanup=T,...){
  command<-paste(command,modelfile," --samples=",nsamp," --seed=",seed," ",addargs,sep="")
  cat(paste(command,"\n"))
  if(.Platform$OS.type == "windows")args<-list(command,intern=F,minimized=F,invisible=F,show.output.on.console=T,wait=T)
  if(.Platform$OS.type != "windows")args<-list(command,wait=T)
  do.call(system,args)
  if(cleanup)cleanup()
}

## ----Bootstrap: Performs bootstrap for a given control file and dataset
bootstrap.PsN<-function(command="c:\\pkpd\\bin\\bootstrap-3.5.4.bat ",modelfile,nsamp,seed,addargs=NULL,cleanup=T,...){
  command<-paste(command,modelfile," --samples=",nsamp," --seed=",seed," ",addargs,sep="")
  cat(paste(command,"\n"))
  if(.Platform$OS.type == "windows")args<-list(command,intern=F,minimized=F,invisible=F,show.output.on.console=T,wait=T)
  if(.Platform$OS.type != "windows")args<-list(command,wait=T)
  do.call(system,args)
  if(cleanup)cleanup()
}

## ----Bootstrap: Performs bootstrap for a given control file and dataset
SSE.PsN<-function(command="c:\\pkpd\\bin\\sse-3.5.4.bat ",modelfile, nsamp, seed,addargs=NULL,cleanup=T,...){
  command<-paste(command, modelfile," --samples=",nsamp," --seed=",seed," ",addargs,sep="")
  cat(paste(command,"\n"))
  if(.Platform$OS.type == "windows")args<-list(command,intern=F,minimized=F,invisible=F,show.output.on.console=T,wait=T)
  if(.Platform$OS.type != "windows")args<-list(command,wait=T)
  do.call(system,args)
  if(cleanup)cleanup()
}

## ---bs.summary: Parses the bootstrap results file
bs.summary<-function(fileName=NULL){
  text<-readLines(fileName)
  
  diagnostics<-read.csv(fileName,skip=grep("^diagnostic",text),header=T,nrows=1)[-1]
  
  means<-read.csv(fileName,skip=grep("^means",text)+1,header=F,nrows=1)[-1]
  names(means)<-gsub("\\s","",read.csv(fileName,skip=grep("^means",text),nrows=1,header=F,stringsAsFactors=F)[-1])
  
  bias<-read.csv(fileName,skip=grep("^bias",text)+1,header=F,nrows=1)[-1]
  names(bias)<-gsub("\\s","",read.csv(fileName,skip=grep("^bias",text),nrows=1,header=F,stringsAsFactors=F)[-1])
  
  se_CI<-read.csv(fileName,skip=grep("^standard.error.confidence",text)+1,nrows=8,header=F,row.names=1)
  names(se_CI)<-gsub("\\s","",read.csv(fileName,skip=grep("^standard.error.confidence",text),nrows=1,header=F,stringsAsFactors=F)[-1])
  row.names(se_CI)<-gsub("\\s","",row.names(se_CI))
  
  se<-read.csv(fileName,skip=grep("^standard.error",text)+1,header=F,nrows=1)[-1]
  names(se)<-gsub("\\s","",read.csv(fileName,skip=grep("^standard.error",text),nrows=1,header=F,stringsAsFactors=F)[-1])
  
  medians<-read.csv(fileName,skip=grep("^medians",text)+1,header=F,nrows=1)[-1]
  names(medians)<-gsub("\\s","",read.csv(fileName,skip=grep("^medians",text),nrows=1,header=F,stringsAsFactors=F)[-1])
  
  perc_CI<-read.csv(fileName,skip=grep("^percentile",text)+1,nrows=8,header=F,row.names=1)
  names(perc_CI)<-gsub("\\s","",read.csv(fileName,skip=grep("^percentile",text),nrows=1,header=F,stringsAsFactors=F)[-1])
  row.names(perc_CI)<-gsub("\\s","",row.names(perc_CI))
  
  out<-list(diagnostics=diagnostics, means=means, bias=bias, se_CI=se_CI, se=se, medians=medians, perc_CI=perc_CI)
  out
}

#' ---cleanup: function to remove NONMEM cruft. 
#' Based on Andy Hooker's cleanup.R function https://github.com/andrewhooker/MBAOD/blob/master/R/cleanup.R 
cleanup <- function(path=getwd(),pattern=NULL,remove.folders=F,...){
  
  orig.dir<-getwd()
  sub.dir<-path
  setwd(sub.dir)
  
  print('- Cleaning up..')
  
  # remove old files before new run
  files<-c("xml","_L","_R", "INTER", "LINK", "nul",
           "nmprd4p.mod", "nonmem",
           "FCON","FDATA","FMSG","fort.6","FREPORT","FSIZES","FSTREAM","FSUBS","fsubs.f90","fsubs.o","FSUBS.MU.F90",
           "GFCOMPILE.BAT","linkc",
           "nmfe72", "set", "newline", "gfortran", "prsizes",
           "trash", "compile", "matlab",
           "garbage.out")
  if(length(pattern)>0) files<-c(files,pattern)
    
  for(f in files){    
    unlink(dir(pattern=f))
  }
  
  # remove PsN folders
  if(remove.folders){
    all <- list.files(all.files=F, full.names=T)
    alldirs<-all[file.info(all)$isdir]
    unlink(alldirs,recursive=T,force=T)
  }  
  
  setwd(orig.dir)
}


### ----updateModel: Change elements of the Model based on inputs
updateModel<-function(parsedObject,
                      theta=parsedObject$Theta,
                      omega=parsedObject$Omega,
                      sigma=parsedObject$Sigma,
                      task=parsedObject$Estimates,
                      data=parsedObject$Data,
                      dataNames=parsedObject$Input,
                      tables=parsedObject$Tables){
  newObject<-parsedObject
  newObject$Theta<-theta
  newObject$Omega<-omega
  newObject$Sigma<-sigma
  newObject$Estimates<-task
  newObject$Data<-data
  newObject$Input<-dataNames
  newObject$Tables<-tables
  newObject
}

### ----writeControlText: Write out a parsed Model as a NONMEM control stream

writeControlText<-function(templateModel,parsedControl, modelfile,modelextension=".mod",
                           modelBlockNames=c("PK","PRE","SUB","MOD","DES","ERR")){
  
  ### Get RAW NM control stream items
  control<-templateModel
  
  ### Where do the various block statements occur?
  blockpos<-grep("^ *[$]",control)
  blocks<-control[blockpos]
  
  ## Drop commented out lines
  ## blocks<-blocks[-grep("[;]",blocks)]
  ### Get first "word" to determine order
  blocks1<-sub( " +.*", "", blocks ) 
  blocks2<-sub("$","",blocks1, fixed=T)
  orig1<-data.frame(block=blocks2,line=blockpos,stringsAsFactors=F)
  orig2<-orig1[!duplicated(orig1$block),]
  
  blocks3<-substr(orig2$block,1,3)
  orig.pos<-c(1:length(blocks3))
  orig<-data.frame(block.id=blocks3,orig.pos=orig.pos,orig.block=orig2$block,line=orig2$line,stringsAsFactors=F)
  
  ### Get list of objects from the parsed Control file
  control2<-parsedControl
  control2Blocks<-substr(casefold(names(control2),upper=T),1,3)
  RNMI.pos<-c(1:length(control2Blocks))
  RNMI<-data.frame(block.id=control2Blocks,RNMI.pos=RNMI.pos,RNMI.block=names(parsedControl),stringsAsFactors=F)
  
  ## Match blocks in control file to  items in the parsed list
  ctrlmerged<-merge(orig,RNMI,by="block.id",all=T)
  ctrlmerged<-ctrlmerged[order(ctrlmerged$orig.pos),]
  ctrlmerged$orig.block[is.na(ctrlmerged$orig.block)]<-casefold(ctrlmerged$RNMI.block[is.na(ctrlmerged$orig.block)],upper=T)

  ## Leave out model related blocks from parsedcontrol
  ## Will pick these up directly from Raw file.
  ## This means that we do not expect user to update the model!
  otherBlocks<-ctrlmerged[!(ctrlmerged$block.id%in%modelBlockNames),]
  control2<-control2[otherBlocks$RNMI.block]
  
  ## If blocks appear in the original, but not RNMImport parsed version
  ## then create RNMImport blocks.
  ## e.g. $DES

  modelBlockCode<-list(NULL)
  modelBlocks<-ctrlmerged[ctrlmerged$block.id%in%modelBlockNames,]
  for(i in 1:nrow(modelBlocks)){
    nextBlock<-ctrlmerged[modelBlocks$orig.pos[i]+1,]
    modelStart<-modelBlocks$line[i]
    modelEnd<-nextBlock$line-1
    
    codeLines <- control[modelStart:modelEnd]
    codeLines<-paste(codeLines,"\n")
    modelBlockCode[[i]]<-codeLines
    names(modelBlockCode)[[i]]<-modelBlocks$orig.block[i]
  }

  addBlocks<-list(NULL)
  missBlocks<-ctrlmerged[is.na(ctrlmerged$RNMI.pos)&!(ctrlmerged$block.id%in%modelBlockNames),]
  if(nrow(missBlocks)>0){
    for(i in 1:nrow(missBlocks)){
      nextBlock<-ctrlmerged[missBlocks$orig.pos[i]+1,]
      missStart<-missBlocks$line[i]+1  ## NOTE! The +1 here might cause trouble!
      missEnd<-nextBlock$line-1
      
      codeLines <- control[missStart:missEnd]
      addBlocks[[i]]<-codeLines
      names(addBlocks)[[i]]<-as.character(missBlocks$block.id[i])
      newRNMIpos<-max(ctrlmerged$RNMI.pos,na.rm=T)+i
      ctrlmerged[ctrlmerged$block.id==missBlocks[i,"block.id"],"RNMI.pos"]<-newRNMIpos
    }
  }
    
  ### Change $THETA -Inf and Inf values to missing
  ### Change $THETA values = 0 to "0 FIX"
  control2$Theta<-formatC(control2$Theta)
  control2$Theta<-apply(control2$Theta,2,function(x)sub("^ *Inf",NA,x))
  control2$Theta<-apply(control2$Theta,2,function(x)sub("^ *-Inf",NA,x))
  control2$Theta[control2$Theta[,1]==control2$Theta[,3],c(1,3)]<-NA
  control2$Theta[control2$Theta[,2]==0,c(1,3)] <- NA
  control2$Theta[control2$Theta[,2]==0,2] <- "0 FIX"
  
  ### Change $OMEGA values = 0 to "0 FIX"
  ### THIS NEEDS WORK!!!
  ### Turn Omega matrix into diagonal etc.
  ### and handle block structures

  Omega<-NULL
  
  ## Are only diagonals filled??
  OmegaDiag<-sum(control2$Omega[lower.tri(control2$Omega,diag=F)])==0
  if(OmegaDiag){
    Omega.blocksize<-NULL
    Omega<-diag(control2$Omega)
    Omega[Omega==0]<-"0 FIX"
    Omega<-sapply(Omega,function(x)paste(x,"\n"))
  }
  if(!OmegaDiag){
    ## Which Omegas are BLOCK
    Corr<-(apply(control2$Omega,2,sum)-diag(control2$Omega))!=0
    block<-paste("BLOCK(",sum(Corr),")\n",sep="")
    Omega1<-control2$Omega[Corr,Corr]
    Omega.1<-paste(Omega1[lower.tri(Omega1,diag=T)],"\n")
    Omega<-list(block,Omega.1)
    if(sum(Corr)!=length(diag(control2$Omega))){
      Omega.2<-diag(control2$Omega[!Corr,!Corr])
      Omega.2[Omega.2==0]<-"0 FIX"
      Omega.2<-sapply(Omega.2,function(x)paste(x,"\n"))
      Omega<-list(block,Omega.1,"\n$OMEGA\n",Omega.2)
    }
  }

  ## Overwrite control2$Omega with Omega above.
  control2$Omega<-Omega
  names(control2$Omega)<-NULL
  
  Sigma<-NULL
  
  ## Are only diagonals filled??
  SigmaDiag<-sum(control2$Sigma[lower.tri(control2$Sigma,diag=F)])==0
  if(SigmaDiag){
    Sigma.blocksize<-NULL
    Sigma<-diag(control2$Sigma)
    Sigma[Sigma==0]<-"0 FIX"
    Sigma<-sapply(Sigma,function(x)paste(x,"\n"))
  }
  if(!SigmaDiag){
    ## Which Sigmas are BLOCK
    Corr<-(apply(control2$Sigma,2,sum)-diag(control2$Sigma))!=0
    block<-paste("BLOCK(",sum(Corr),")\n",sep="")
    Sigma1<-control2$Sigma[Corr,Corr]
    Sigma.1<-paste(Sigma1[lower.tri(Sigma1,diag=T)],"\n")
    Sigma<-list(block,Sigma.1)
    if(sum(Corr)!=length(diag(control2$Sigma))){
      Sigma.2<-diag(control2$Sigma[!Corr,!Corr])
      Sigma.2[Sigma.2==0]<-"0 FIX"
      Sigma.2<-sapply(Sigma.2,function(x)paste(x,"\n"))
      Sigma<-list(block,Sigma.1,"\n$Sigma\n",Sigma.2)
    }
  }
  
  control2$Sigma<-Sigma
  names(control2$Sigma)<-NULL

  ####################################################################
  ### PREPARE ITEMS IN CONTROL2 FOR WRITING OUT
  ####################################################################
  
  ## $INPUT records - Paste together the variables names and labels
  ## e.g. SID=ID TIME=TIME AMT=AMT BWT=DROP MDV=MDV DV=DV
  ## More detail than necessary / usual, but consistent with RNMImport object
  
  #### If the two are equal then write only one
  
  Input<-control2$Input[,"nmName"]
  diffInput<-control2$Input[,"nmName"]!=control2$Input[,"Label"]
  if(any(diffInput)){
    Input[diffInput]<-paste(control2$Input[diffInput,"nmName"],control2$Input[diffInput,"Label"],sep="=")
  }
  
  control2$Input<-Input
  
  ## $DATA records - Paste together commands and attributes
  ##  e.g. THEO.DAT IGNORE=# etc.
  
  Data<-paste("'",control2$Data[1],"'",sep="")
  
  if(control2$Data[2]!="NONE"){
    colnames(control2$Data)[2]<-"IGNORE"
    ignoreAccept<-paste(colnames(control2$Data),control2$Data,sep="=")[c(2,3)]
    ignoreAccept<-ignoreAccept[grep(".",control2$Data[c(2,3)])]  ## Non-missing
    if(grep(";",ignoreAccept)>0){
      ignoreAccept<-unlist(strsplit(ignoreAccept,";"))
      ignoreAccept2<-sapply(ignoreAccept[-1],function(x)paste("\n IGNORE=",x,sep=""))
      ignoreAccept<-c(ignoreAccept[1],ignoreAccept2)
    }
    ### Change $DATA REWIND statement to NOREWIND rather than REWIND=FALSE
    control2$Data[4]<-ifelse(control2$Data[4]=="FALSE","NOREWIND","")
    
    Data<-c(control2$Data[1], ignoreAccept)
  }
  control2$Data<-Data
  
  ## Omit Data file commands that have no attributes
  
  ## Combine $THETA bounds into usual NONMEM format
  ## e.g. (0, 0.5, ) OR 0.5 OR (,0.5,1000)
  Theta<-paste("(",apply(control2$Theta,1,function(x){paste(x,collapse=",")}),")\n")
  Theta<-gsub("NA","",Theta)
  Theta[is.na(control2$Theta[,1]) & is.na(control2$Theta[,3])]<-paste(control2$Theta[is.na(control2$Theta[,1]) & is.na(control2$Theta[,3]),2],"\n")
  
  control2$Theta<-Theta
  
  ## Prepare $OMEGA for printings
  
  control2$Omega<-print(unlist(control2$Omega,as.character))
  
  ## Check for existence of $Tables in original code
  if(length(control2$Tables)){
    ## Collect $TABLE variable strings, delete comma separator, append ONEHEADER NOPRINT statements
    Tables<-
      apply(control2$Table,1,function(x){paste(
        "$TABLE ",
        gsub(",","",x[2])
        ," ONEHEADER NOPRINT FILE=",x[1],"\n",sep="")})
    ## First $Table statement doesn't need "$Table" since it comes from ctrlmerged if present
    if(!is.na(ctrlmerged$orig.block[ctrlmerged$block.id=="TAB"]))Tables[1]<-sub("^\\$TABLE","",Tables[1],perl=T)
    Tables<-gsub("ETA\\.","ETA\\(",Tables,perl=T)
    Tables<-gsub("\\.","\\)",Tables,perl=T)
    control2$Tables<-Tables
  }
  
  control3<-list(NULL)
  for(i in 1:nrow(ctrlmerged)){
    if(ctrlmerged$block.id[i]%in%otherBlocks$block.id)control3[[i]]<-control2[[ctrlmerged$RNMI.block[i]]]
    if(ctrlmerged$block.id[i]%in%modelBlockNames)control3[[i]]<-modelBlockCode[[ctrlmerged$orig.block[i]]]
    names(control3)[[i]]<-ctrlmerged$orig.block[i]
  }
  
  
  #####################################
  #####################################
  ## Writing out the control statements
  #####################################
  #####################################
  
  ### PROBABLY NEEDS BETTER HANDLING OF ORDER OF BLOCKS IN THE NONMEM CODE
  ### USE RULES FROM NONMEM HELP GUIDES?
  ### FOR NOW BASED ON ORDER IN ORIGINAL NM CODE
  ### IF ITEMS ADDED THROUGH updateMOG(...) THEN ADD THESE AT THE END?
  ### USUALLY TABLE ITEMS

  ## "special" blocks need $ statement on one line and content below
  special<-is.element(ctrlmerged$block.id,c("PK","PRED","ERR","THE","OME","SIG","DES","MOD"))
  model<-is.element(ctrlmerged$block.id,modelBlockNames)
  ctrlmerged$orig.block[special]<-paste(ctrlmerged$orig.block[special],"\n")
  ctrlmerged$orig.block[model]<-""
  
  sink(file=paste(modelfile,modelextension,sep=""))
  for (i in 1:nrow(ctrlmerged)){
    if(!ctrlmerged$block.id[i]%in%modelBlockNames)cat(paste("$",ctrlmerged$orig.block[i]," ",sep=""))
    cat(paste(cat(control3[[i]]),"\n"))
  }
  sink()
}
