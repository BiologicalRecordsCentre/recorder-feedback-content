# This is a script that can be run from command line (e.g. on a schedule) 

#activate the renv environment
source("renv/activate.R")

# run the pipeline
targets::tar_make()