# This is a script that can be run from command line (e.g. on a schedule) 
print(getwd())
setwd("./R/myrecord_weekly")
print(getwd())

if(!require(renv)){
  install.packages("renv",repos='http://cran.r-project.org')
  library(renv)
}

#activate the renv environment
source("renv/activate.R")
renv::restore()

# run the pipeline
targets::tar_make()
