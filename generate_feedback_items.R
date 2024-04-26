# This is a script that can be run from command line (e.g. on a schedule) 
print(getwd())
setwd("C:/Users/simrol/Documents/python/recorder-feedback-controller/R/myrecord_weekly")
print(getwd())

if(!require(renv)){
  install.packages("renv")
  library(renv)
}

#activate the renv environment
source("renv/activate.R")

# run the pipeline
targets::tar_make()
