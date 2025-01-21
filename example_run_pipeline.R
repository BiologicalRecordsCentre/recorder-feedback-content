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

# GATHER
source("R/gather/get_subscribers_from_controller.R")
# Get subscribers for the list and write the data frame
subscribers_df <- get_subscribers_from_controller(api_url = config$controller_app_base_url, 
                                                  email_list_id = config$controller_app_list_id, 
                                                  api_token = config$controller_app_api_key) 
write.csv(subscribers_df,config$participant_data_file,row.names = F)

# get records data
#TBC


# GENERATE
#run the pipeline
Sys.setenv(BATCH_ID = batch_id) # Set an environment variable in R for the batch code
targets::tar_make() # run the pipeline
Sys.unsetenv("BATCH_ID") #and unset the variable


#SEND
source("R/send/send_single_email.R")
source("R/send/send_notify_app.R")

meta_table <-read.csv(paste0("renders/",batch_id,"/meta_table.csv"))
participants <- read.csv(config$participant_data_file)

#here we are going through all the users and sending email
for (i in 1:nrow(meta_table)){
  send_single_email(
    recipient = meta_table[i,"email"],
    email_file = meta_table$file[i])
  
  send_notify_app(
    content_key = meta_table[i,"content_key"],
    user_external_key = meta_table[i,"user_id"],
    batch_id = batch_id
  )
  
  #send_single_email(recipient,email_content)
}
