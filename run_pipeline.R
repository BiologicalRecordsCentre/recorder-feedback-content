#PREP
#generating batch_id
batch_id <- paste0(Sys.Date(),"-",paste(sample(letters,10),collapse = ""))

#load packages
library(httr)
library(jsonlite)
library(curl)

#load configuration from config.yml using config package
config <- config::get()

# Get users
if(config$gather_from_controller_app){
  # GATHER
  source("R/gather/get_subscribers_from_controller.R")
  # Get subscribers for the list and write the data frame
  subscribers_df <- get_subscribers_from_controller(api_url = config$controller_app_base_url, 
                                                    email_list_id = config$controller_app_list_id, 
                                                    api_token = config$controller_app_api_key) 
  write.csv(subscribers_df,config$participant_data_file,row.names = F)
}


# get their records using this script which will save data to config$data_file
source(config$gather_bio_script)

# check that records have been updated
if(difftime(file.info(config$data_file)$mtime,Sys.time(),units = "secs") < 30){
  print("Biodiversity data file has been updated")
} else {
  stop("Biodiversity data file has not been updated, check for issue in gather script")
}


# GENERATE
#run the pipeline
Sys.setenv(BATCH_ID = batch_id) # Set an environment variable in R for the batch code
targets::tar_make() # run the pipeline
Sys.unsetenv("BATCH_ID") #and unset the variable

#SEND

#maintain a dataframe with the email and any errors that arise when sending
status_log <- data.frame(
  user_id = character(),
  email = character(),
  status = character(),
  message = character(),
  stringsAsFactors = FALSE
)

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
meta_table$email <- "simon.p.rolph@gmail.com"
participants <- read.csv(config$participant_data_file)
participants$email <- "simon.p.rolph@gmail.com"

#here we are going through all the users and sending email
if (!is.data.frame(meta_table)) {
  stop("meta_table must be a data frame.")
}

for (i in 1:nrow(meta_table)) {
  
  result <- tryCatch({
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
    
    
    #check email is in content
    lines_read <- paste0(readLines(file),collapse = "")
    if(grepl(email, lines_read, fixed = TRUE)==FALSE){
      stop("Target email address is different to email listed in footer")
    }
    
    # Perform operations
    if(config$gather_from_controller_app){
      send_notify_app(
        content_key = content_key,
        user_external_key = user_id,
        batch_id = batch_id,
        config = config
      )
    }
    
    sender <- config$mail_default_sender
    names(sender) <- config$mail_default_name
    email_obj <- blastula:::cid_images(file)
    
    smtp_send(
        email_obj,
        from = sender,
        to = email,
        subject = config$mail_default_subject,
        credentials = creds,
        verbose = FALSE
      )
      data.frame(
        user_id = user_id,
        email = email,
        status = "Success",
        message = "Email sent",
        stringsAsFactors = FALSE
      )
    }, error = function(e) {
      print("Email not sent")
      data.frame(
        user_id = user_id,
        email = email,
        status = "Failed",
        message = e$message,
        stringsAsFactors = FALSE
      )
    })
  status_log <- rbind(status_log,result)
}

status_lines <- apply(status_log, 1, function(row) {
  paste(
    "User ID:", row["user_id"], 
    "| Email:", row["email"], 
    "| Status:", row["status"], 
    "| Message:", row["message"]
  )
})

report_email <- compose_email(
  body = md(
    paste0(
      "### Email Send Summary",
      "
      Total attempted: ", nrow(status_log),
      "
      ✅ Success: ", sum(status_log$status == "Success"), 
      "
      ❌ Failed: ", sum(status_log$status == "Failed"),
      "
      Please check logs for more information"
    )
    ),
  footer = Sys.time()
  )

smtp_send(
  email = report_email,
  from = sender,
  to = config$mail_test_recipient,  # your email
  subject = paste("Email Batch Status Report -", Sys.Date()),
  credentials = creds,
  verbose = FALSE
)
