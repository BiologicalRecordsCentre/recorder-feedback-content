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
library(httr)
library(jsonlite)
library(curl)
source("R/gather/get_records_from_indicia.R")

records_data <- data.frame()#create an empty data frame
for (i in 1:nrow(subscribers_df)){
  data_out <- get_user_records_from_indicia(base_url = config$indicia_warehouse_base_url, 
                                            client_id = config$indicia_warehouse_client_id,
                                            shared_secret = config$indicia_warehouse_secret,
                                            user_warehouse_id = subscribers_df$user_id[i],
                                            n_records = 5)
  
  if (data_out$hits$total$value >0){
    #any intermediate data processing
    latlong <- data_out$hits$hits$`_source`$location$point
    
    #extract all the columns you need
    user_records <- data.frame(latitude = strsplit(latlong,",")[[1]][1],
                               longitude = strsplit(latlong,",")[[1]][2],
                               species = data_out$hits$hits$`_source`$taxon$taxon_name,
                               species_vernacular = data_out$hits$hits$`_source`$taxon$vernacular_name,
                               date = data_out$hits$hits$`_source`$event$date_start,
                               user_id = data_out$hits$hits$`_source`$metadata$created_by_id
    )
    
    records_data <- rbind(records_data,user_records)
  }
}

write.csv(records_data,config$data_file,row.names = F)#save the data



# GENERATE
#run the pipeline
Sys.setenv(BATCH_ID = batch_id) # Set an environment variable in R for the batch code
targets::tar_make() # run the pipeline
Sys.unsetenv("BATCH_ID") #and unset the variable


#SEND
source("R/send/send_single_email.R")
source("R/send/send_notify_app.R")
library(blastula)

Sys.setenv(SMTP_PASSWORD = config$mail_password)
creds <- creds_envvar(
  user = config$mail_username,
  pass_envvar = "SMTP_PASSWORD",
  host = config$mail_server,
  port = config$mail_port,
  use_ssl = config$mail_use_ssl)

meta_table <-read.csv(paste0("renders/",batch_id,"/meta_table.csv"))
participants <- read.csv(config$participant_data_file)

#here we are going through all the users and sending email
for (i in 1:nrow(meta_table)){
  
  send_notify_app(
    content_key = meta_table[i,"content_key"],
    user_external_key = meta_table[i,"user_id"],
    batch_id = batch_id
    )
  
  email_obj <- blastula:::cid_images(meta_table[i,"file"])
  smtp_send(email_obj,
            from = config$mail_default_sender,
            to = meta_table[i,"email"],
            subject = config$mail_default_subject,
            credentials = creds,
            verbose = F
  )
  
}
