## ----------------------------------------------------
## Created by Mindul Consulting LLC
## Author : Mayank Tandon, Bhupendra Tandon
## Date   :01-AUG-2014
## ----------------------------------------------------
library(streamR)

args <- commandArgs(trailingOnly = TRUE)

queryText = args[1]
captureTime = as.numeric(args[2])
twFileName = args[3]

if (file.access(twFileName,mode=2)) {
  print(paste("query: ",queryText,",  time: ",captureTime,",  file: ",twFileName))
  load("my_oauth.Rdata")
  filterStream(file.name = twFileName, track = queryText, timeout = captureTime, oauth = my_oauth)
} else {
  print("No write permissions.")
}
