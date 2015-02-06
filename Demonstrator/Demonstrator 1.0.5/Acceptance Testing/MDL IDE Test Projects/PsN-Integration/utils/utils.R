printMessage <- function(message) {
	print(paste(replicate(60, "#"), collapse = ""))
	print(message)
	print(paste(replicate(60, "#"), collapse = ""))
}