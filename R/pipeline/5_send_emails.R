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
participants <- read.csv(config$participant_data_file)

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
