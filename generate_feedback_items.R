args <- commandArgs(TRUE)
batch_id <- args[1]

# This is a script that can be run from command line (e.g. on a schedule) 
setwd("./R/myrecord_weekly")

if(!require(renv)){
  install.packages("renv",repos='http://cran.r-project.org')
  library(renv)
}

#activate the renv environment
source("renv/activate.R")
renv::restore()

# Set an environment variable in R for the batch code
Sys.setenv(BATCH_ID = batch_id)

# run the pipeline
targets::tar_make()

#and unset the variable
Sys.unsetenv("BATCH_ID")