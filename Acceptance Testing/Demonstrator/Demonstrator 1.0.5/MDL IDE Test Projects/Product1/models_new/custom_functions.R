plot_bootstrap <- function(resultsDir) {
	rawresults <- grep('^raw_results_[[:alnum:]|-|_]+.csv$',dir(resultsDir),fixed=FALSE,invert=FALSE,value=TRUE)
	bootresults <- grep('bootstrap_results.csv',dir(resultsDir),fixed=TRUE,invert=FALSE,value=TRUE)
	#TODO check output object errors before doing things here
	if (length(rawresults)==1 && length(bootresults)==1 ){
		plots<-boot.hist(results.file=file.path(resultsDir,rawresults[1]),incl.ids.file=file.path(resultsDir,"included_individuals1.csv"))
		print(plots)
	} else {
		#we can only get here if psngeneric connector sets exit 0 even if return status of bootstrap command was non-zero
		logfile <- grep('.psn.log$',dir(resultsDir),fixed=FALSE,invert=FALSE,value=TRUE)
		if (length(logfile)==1) {	
			warning('could not find bootstrap results in ',resultsDir,'. Check error messages in ',file.path(resultsDir,logfile[1]))
		} else {
			warning('could not find bootstrap results in ',resultsDir)
		}
	}
}