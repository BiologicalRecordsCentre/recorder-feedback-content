source("R/send/send_email.R")
source("R/send/send_notify_app.R")

list_id <- config$controller_app_list_id
meta_table <-read.csv(paste0("renders/",batch_id,"/meta_table.csv"))
participants <- read.csv(config$participant_data_file)

#here we are going through all the users and sending email
for (i in 1:nrow(meta_table)){
  send_single_email(
    recipient = meta_table[i,"email"],
    email_file = meta_table$file[i])
  
  send_notify_app(
    content_key, user_external_key = meta_table[i,"id"], batch_id = batch_id
  )
  
  
  send_email(recipient,email_content)
}
