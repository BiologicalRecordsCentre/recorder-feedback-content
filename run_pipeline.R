#Sys.setenv(R_CONFIG_ACTIVE = "default") # running locally for development
#Sys.setenv(R_CONFIG_ACTIVE = "rsconnect") #running on posit connect

#PREP
#generating batch_id
batch_id <- paste0(Sys.Date(),"-",paste(sample(letters,10),collapse = ""))

# Renv configuration
if(!require(renv)){
  install.packages("renv",repos='http://cran.r-project.org')
  library(renv)
}

#posit connect automatically sets up the renv environment, but if not using rsconnect then you need to manually initiate the renv environment
if(Sys.getenv("R_CONFIG_ACTIVE") != "rsconnect"){ 
  source("renv/activate.R") #activate the renv environment
  renv::restore() #restore packages
}

#packages
library(httr)
library(jsonlite)
library(curl)

#load configuration from config.yml using config package
config <- config::get()

#export the R code from here as a R file
#knitr::purl(input = "run_pipeline.Rmd", output = "run_pipeline.R",documentation = 0)

# GATHER
source("R/gather/get_subscribers_from_controller.R")
# Get subscribers for the list and write the data frame
subscribers_df <- get_subscribers_from_controller(api_url = config$controller_app_base_url, 
                                                  email_list_id = config$controller_app_list_id, 
                                                  api_token = config$controller_app_api_key) 
write.csv(subscribers_df,config$participant_data_file,row.names = F)

# get records data
source("R/gather/get_records_from_indicia.R")
records_data <- data.frame()#create an empty data frame
for (i in 1:nrow(subscribers_df)){
  data_out <- get_user_records_from_indicia(base_url = config$indicia_warehouse_base_url, 
                                            client_id = config$indicia_warehouse_client_id,
                                            shared_secret = config$indicia_warehouse_secret,
                                            user_warehouse_id = subscribers_df$user_id[i],
                                            n_records = 100)
  
  if (data_out$hits$total$value >0){
    #any intermediate data processing
    latlong <- data_out$hits$hits$`_source`$location$point
    
    #extract all the columns you need
    vernacular_names <- data_out$hits$hits$`_source`$taxon$vernacular_name
    if(is.null(vernacular_names)){vernacular_names[is.null(vernacular_names)]<-""}
    
    user_records <- data.frame(latitude = sub(",.*", "", latlong),
                               longitude = sub(".*,", "", latlong),
                               species = data_out$hits$hits$`_source`$taxon$taxon_name,
                               species_vernacular = vernacular_names,
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
source("R/send/send_notify_app.R")
library(blastula)

if(config$mail_creds == "envvar"){
  Sys.setenv(SMTP_PASSWORD = config$mail_password)
  creds <- creds_envvar(
    user = config$mail_username,
    pass_envvar = "SMTP_PASSWORD",
    host = config$mail_server,
    port = config$mail_port,
    use_ssl = config$mail_use_ssl)
}

if(config$mail_creds == "anonymous"){
  creds <- creds_anonymous(host = config$mail_server,port=config$mail_port,use_ssl = config$mail_use_ssl)
}

meta_table <-read.csv(paste0("renders/",batch_id,"/meta_table.csv"))
participants <- read.csv(config$participant_data_file)

#here we are going through all the users and sending email
if (!is.data.frame(meta_table)) {
  stop("meta_table must be a data frame.")
}

for (i in 1:nrow(meta_table)) {
  # Debug: Print current row being processed
  print(paste("Processing row:", i))
  
  # Check for required columns in meta_table
  if (!all(c("content_key", "user_id", "file", "email") %in% colnames(meta_table))) {
    stop("meta_table is missing required columns.")
  }
  
  # Safely extract values
  content_key <- meta_table[i, "content_key"]
  user_id <- meta_table[i, "user_id"]
  file <- meta_table[i, "file"]
  email <- meta_table[i, "email"]
  
  # Perform operations
  send_notify_app(
    content_key = content_key,
    user_external_key = user_id,
    batch_id = batch_id,
    config = config
  )
  
  sender <- config$mail_default_sender
  names(sender) <- config$mail_default_name
  
  email_obj <- blastula:::cid_images(file)
  smtp_send(email_obj,
            from = sender,
            to = email,
            subject = config$mail_default_subject,
            credentials = creds,
            verbose = FALSE
  )
}
