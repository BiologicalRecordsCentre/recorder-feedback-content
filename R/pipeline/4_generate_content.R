# GENERATE
#run the pipeline
Sys.setenv(BATCH_ID = batch_id) # Set an environment variable in R for the batch code
targets::tar_make() # run the pipeline
Sys.unsetenv("BATCH_ID") #and unset the variable
