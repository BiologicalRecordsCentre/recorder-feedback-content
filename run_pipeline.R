# This is a script that can be run from command line (e.g. on a schedule) 

#STEP 1
#getting or generating batch_id
args <- commandArgs(TRUE) # get batch id from command line 
if (length(args)>0){
  batch_id <- args[1]
} else { #set a batch id to date + random letters
  batch_id <- paste0(Sys.Date(),"-",paste(sample(letters,10),collapse = ""))
}

config <- config::get()

# this may need to be set if calling from the recorder feedback controller
#setwd("./R/recorder-feedback-content")

if(!require(renv)){
  install.packages("renv",repos='http://cran.r-project.org')
  library(renv)
}

#activate the renv environment
source("renv/activate.R")
renv::restore()

# OPTIONAL: Get data (if using external sources)
source("R/get_users_and_records.R")

# Set an environment variable in R for the batch code
Sys.setenv(BATCH_ID = batch_id)

# run the pipeline
targets::tar_make()

#and unset the variable
Sys.unsetenv("BATCH_ID")

# OPTIONAL: send the emails
source("R/send_email.R")
meta_table <-read.csv(paste0("renders/",batch_id,"/meta_table_",batch_id,".csv"))
for (i in 1:nrow(meta_table)){
  #get their email address
  participants <- read.csv(config$participant_data_file)
  recipient <- participants[participants$user_id == meta_table[i,"user_id"],]$email
  send_email(recipient,meta_table$file[i])
}
